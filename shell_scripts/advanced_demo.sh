#!/bin/bash

graph_files=("sportvoeux4.txt" "sportvoeux5.txt" "sportvoeux6.txt")

original_script="./example_medium.sh"  # Adjust this path if necessary

ORANGE='\033[38;5;214m'  # Orange color code
RESET='\033[0m'  # Reset color code

# Loop through the graph files and call the original script with each file
for graph_file in "${graph_files[@]}"; do
    echo -e "${ORANGE}🤞 Starting example_medium.sh with graph file: $graph_file 🤞${RESET}"
    $original_script $graph_file
    echo -e "${ORANGE}✅ Finished processing $graph_file ✅${RESET}"
    echo -e "${ORANGE}--------------------------------------------${RESET}"
done

