#!/usr/bin/env bash

#!/bin/bash

# --- Configuration ---
# Your Reddit username or a descriptive string for the User-Agent.
# This is important to identify your requests to Reddit's API.
USER_AGENT="BashImageGrabber/1.0 (by /u/YourRedditUsername)"

# List of subreddits to grab images from
SUBREDDITS=(
    "EarthPorn"
    "CityPorn"
    "SpacePorn"
    "ExposurePorn"
    "ArchitecturePorn"
    "NatureIsFuckingLit"
    "MostBeautiful"
    "RuralPorn"
    "WaterPorn"
    "SkyPorn"
    "UnitedStatesofAmerica"
)

# Number of posts to retrieve from each subreddit (max 100 per request)
LIMIT=100

# Sorting option for posts (hot, new, top, controversial, etc.)
# For "nice images", "top" is often a good choice, especially with a time period.
# TOP_SORT_PERIOD="all" # Options: hour, day, week, month, year, all
SORT_BY="top"
SORT_PERIOD="month" # Only relevant if SORT_BY is "top" or "controversial"

# --- Script Logic ---

echo "Starting image list retrieval for ${#SUBREDDITS[@]} subreddits..."
echo "Output files will be named <subreddit_name>.m3u"
echo "---------------------------------------------------"

for SUBREDDIT in "${SUBREDDITS[@]}"; do
    OUTPUT_FILE="${SUBREDDIT}.m3u"
    API_URL="https://www.reddit.com/r/${SUBREDDIT}/${SORT_BY}/.json?limit=${LIMIT}"

    if [ "$SORT_BY" == "top" ] || [ "$SORT_BY" == "controversial" ]; then
        API_URL="${API_URL}&t=${SORT_PERIOD}"
    fi

    echo "Processing r/${SUBREDDIT} (grabbing ${SORT_BY} posts from ${SORT_PERIOD} period)..."
    echo "#EXTM3U - ${SUBREDDIT} Images (${SORT_BY} ${SORT_PERIOD})" > "$OUTPUT_FILE" # M3U header

    curl -s -A "$USER_AGENT" "$API_URL" | \
    jq -r '.data.children[] | select(.data.post_hint == "image" or (.data.url | test("\\.(jpg|jpeg|png|gif|webp)$"; "i"))) | .data.url' >> "$OUTPUT_FILE"

    if [ $? -eq 0 ]; then
        NUM_IMAGES=$(wc -l < "$OUTPUT_FILE")
        # Subtract 1 for the #EXTM3U header line
        NUM_IMAGES=$((NUM_IMAGES - 1))
        echo "  - Successfully saved ${NUM_IMAGES} image URLs to ${OUTPUT_FILE}"
    else
        echo "  - Failed to retrieve images for r/${SUBREDDIT}. Check connection or subreddit name."
    fi

    # Be nice to Reddit's API - wait a bit between requests
    sleep 2 # Wait 2 seconds
done

echo "---------------------------------------------------"
echo "Image list retrieval complete."
echo "You can find the lists in the current directory."
