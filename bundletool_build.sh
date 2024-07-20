#!/bin/bash

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local response

    read -p "$prompt [$default]: " response
    echo "${response:-$default}"
}

# Function to find files in current and parent directory
find_files() {
    local extension="$1"
    local files=($(find . .. -maxdepth 1 -name "*.$extension"))
    echo "${files[@]}"
}

# Function to list files of a certain type in current and parent directory
list_files() {
    local extension="$1"
    local files=($(find_files "$extension"))
    if [ ${#files[@]} -eq 0 ]; then
        echo "No .$extension files found in current or parent directory"
        return 1
    fi
    for i in "${!files[@]}"; do
        echo "$((i+1)). ${files[i]#./}"
    done
    return 0
}

# Function to select a file from a list
select_file() {
    local extension="$1"
    local prompt="$2"
    local selection

    if ! list_files "$extension"; then
        return 1
    fi

    while true; do
        read -p "$prompt: " selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#files[@]}" ]; then
            echo "${files[$((selection-1))]}"
            return 0
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# Function to generate a new keystore
generate_keystore() {
    local keystore_file="$1"
    local key_alias="$2"
    local key_password="$3"
    local validity_days=10000  # Set validity to about 27 years

    keytool -genkey -v -keystore "$keystore_file" -alias "$key_alias" -keyalg RSA -keysize 2048 -validity $validity_days -storepass "$key_password" -keypass "$key_password" -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, S=Unknown, C=Unknown"

    if [ $? -eq 0 ]; then
        echo "Keystore generated successfully."
        return 0
    else
        echo "Failed to generate keystore."
        return 1
    fi
}

# Prompt for universal mode
universal_mode=$(prompt_with_default "Enable universal mode? (yes/no)" "no")

# Prompt for directory (now optional)
dir=$(prompt_with_default "Enter directory for .aab and .apks files (press Enter to use current and parent directory)" "")

# If no directory is specified, use current directory
if [ -z "$dir" ]; then
    dir="."
fi

# Select .aab file
aab_file=$(select_file "aab" "Select the .aab file")
if [ $? -ne 0 ]; then
    echo "No .aab file found. Exiting."
    exit 1
fi

# Select .apks file (if exists)
apks_file=$(select_file "apks" "Select the .apks file (or press Enter to skip)")

# Prompt for keystore options
keystore_option=$(prompt_with_default "Do you want to use an existing keystore or generate a new one? (existing/new)" "existing")

if [ "$keystore_option" = "existing" ]; then
    # Prompt for JKS key file
    jks_file=$(prompt_with_default "Enter path to JKS key file" "")

    # Prompt for key password
    read -s -p "Enter key password: " key_password
    echo

    # Prompt for key alias
    key_alias=$(prompt_with_default "Enter key alias" "")
else
    # Generate new keystore
    jks_file="${dir}/new_keystore.jks"
    key_alias=$(prompt_with_default "Enter new key alias" "my-key-alias")
    read -s -p "Enter new key password: " key_password
    echo

    if generate_keystore "$jks_file" "$key_alias" "$key_password"; then
        # Save keystore details securely
        details_file="${dir}/keystore_details.txt"
        echo "Keystore file: $jks_file" > "$details_file"
        echo "Key alias: $key_alias" >> "$details_file"
        echo "Key password: $key_password" >> "$details_file"
        chmod 600 "$details_file"
        echo "Keystore details saved to $details_file. Please store this file securely and then delete it."
    else
        exit 1
    fi
fi

# Build command
build_cmd="bundletool build-apks --bundle=$aab_file --output=${aab_file%.aab}.apks"
if [ "$universal_mode" = "yes" ]; then
    build_cmd+=" --mode=universal"
fi
if [ -n "$jks_file" ]; then
    build_cmd+=" --ks=$jks_file --ks-pass=pass:$key_password --ks-key-alias=$key_alias"
fi

# Execute build command
echo "Executing: $build_cmd"
eval $build_cmd

# Prompt to unpack APKS file
if [ -n "$apks_file" ]; then
    unpack=$(prompt_with_default "Do you want to unpack the APKS file? (yes/no)" "no")
    if [ "$unpack" = "yes" ]; then
        unpack_dir="${apks_file%.apks}_unpacked"
        mkdir -p "$unpack_dir"
        unpack_cmd="bundletool extract-apks --apks=$apks_file --output-dir=$unpack_dir"
        echo "Executing: $unpack_cmd"
        eval $unpack_cmd
    fi
fi

echo "Script completed."
