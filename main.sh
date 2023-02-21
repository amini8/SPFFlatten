#!/bin/bash

# Function to extract mechanisms from an SPF record
extract_mechanisms() {
    local spf_record="$1"
    local mechanism_regex="([+~-])?([a-z]+)(:.+)?"
    local mechanism
    local result=""

    # Loop through each mechanism in the SPF record
    while [[ "$spf_record" =~ $mechanism_regex ]]; do
        mechanism="${BASH_REMATCH[0]}"
        result+=" $mechanism"
        spf_record="${spf_record/${BASH_REMATCH[0]}/}"
    done

    echo "$result"
}

# Function to flatten an SPF record
flatten_spf_record() {
    local spf_record="$1"
    local mechanisms=($(extract_mechanisms "$spf_record"))
    local flattened_record=""
    local current_mechanism
    local previous_mechanism

    # Loop through each mechanism in the SPF record
    for (( i=0; i<${#mechanisms[@]}; i++ )); do
        current_mechanism="${mechanisms[$i]}"

        # Skip the "v=spf1" tag
        if [[ "$current_mechanism" == "v=spf1" ]]; then
            continue
        fi

        # Add the "all" mechanism if this is the last mechanism
        if [[ $i -eq $((${#mechanisms[@]} - 1)) ]]; then
            current_mechanism="all"
        fi

        # Remove redundant mechanisms
        if [[ "$current_mechanism" == "$previous_mechanism" ]]; then
            continue
        fi

        flattened_record+=" $current_mechanism"
        previous_mechanism="$current_mechanism"
    done

    # Add the "v=spf1" tag at the beginning
    flattened_record="v=spf1$flattened_record"

    echo "$flattened_record"
}

# Prompt user for SPF record
read -p "Enter the SPF record to flatten: " spf_record

# Flatten the SPF record
flattened_record=$(flatten_spf_record "$spf_record")

echo "Flattened SPF record:"
echo "$flattened_record"
