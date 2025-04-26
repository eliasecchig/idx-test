# No user-configurable parameters
# Accept additional arguments to this template corresponding to template
# parameter IDs
{ pkgs, agent_name ? "", google_cloud_project_id ? "", ... }: {
  # Shell script that produces the final environment
  bootstrap = ''
    # Store the original WS_NAME before modifying it
    original_ws_name="${WS_NAME}" 
    
    # --- Fix 1: Copy contents of current directory ---
    # cp -r "$PWD"/. "$out" is a robust way to copy contents, including hidden files,
    # from the current directory ($PWD) to the destination ($out).
    # Assumes $out exists and is a directory. Add error handling.
    if [ -z "${out:-}" ]; then
      echo "Error: \$out variable is not set." >&2
      exit 1
    fi
    # Check if $out exists and is a directory, or try to create it
    if [ ! -d "$out" ]; then
        echo "Destination directory '$out' does not exist. Creating it."
        mkdir -p "$out" || { echo "Error: Could not create directory '$out'"; exit 1; }
    fi
    
    echo "Copying contents of '$PWD' to '$out'..."
    # Using shopt -s dotglob would also work with cp *, but "$PWD"/ . "$out" is often cleaner
    cp -r "$PWD"/. "$out"/ || { echo "Error: Failed to copy files to '$out'"; exit 1; }
    
    
    # --- Fix 2: Reorder variable modifications and .env logic ---
    # Set shell variables based on original and new names
    # Let AGENT_NAME in the shell be the original base name
    export AGENT_NAME="$original_ws_name"
    # Redefine and export WS_NAME with the suffix
    export WS_NAME="${original_ws_name}-ws" # This will be the new value for subsequent commands and .env
    
    echo "Setting WS_NAME shell variable to: $WS_NAME"
    echo "Setting AGENT_NAME shell variable to: $AGENT_NAME"
    
    
    # --- Fix 6: Set permissions (quoting is already there, adding error check) ---
    echo "Setting permissions on '$out'..."
    chmod -R +w "$out" || { echo "Error: Failed to set permissions on '$out'"; exit 1; }
    
    
    # --- Fix 2, 5, 6: Create .env file ---
    # Use the original_ws_name for AGENT_NAME in the file
    # Use the new WS_NAME value for WS_NAME in the file
    # Use the shell variable $google_cloud_project_id
    echo "Creating .env file at '$out/.env'..."
    cat > "$out/.env" << EOF
    AGENT_NAME=$original_ws_name
    GOOGLE_CLOUD_PROJECT=${google_cloud_project_id:-} # Use default value if unset
    WS_NAME=$WS_NAME
    EOF
    # Check if the heredoc was written successfully
    if [ $? -ne 0 ]; then
        echo "Error: Failed to write to '$out/.env'" >&2
        exit 1
    fi
    
    
    # --- Fix 3, 4, 6: Remove template files and .git directory ---
    # Fix ~ expansion using $HOME variable
    # Fix brace expansion by listing files explicitly
    # Check if files/directories exist before attempting removal
    
    # Use the modified WS_NAME for the removal paths
    git_dir_path="$HOME/$WS_NAME/.git"
    template_nix_path="$HOME/$WS_NAME/idx-template.nix"
    template_json_path="$HOME/$WS_NAME/idx-template.json"
    
    echo "Removing template files and git repository from '$HOME/$WS_NAME'..."
    
    # Remove .git directory if it exists
    if [ -d "$git_dir_path" ]; then
        echo "Removing git repository '$git_dir_path'"
        rm -rf "$git_dir_path" || echo "Warning: Failed to remove '$git_dir_path'" >&2
    else
        echo "Git repository '$git_dir_path' not found, skipping removal."
    fi
    
    # Remove template files if they exist
    if [ -f "$template_nix_path" ]; then
        echo "Removing template file '$template_nix_path'"
        rm -f "$template_nix_path" || echo "Warning: Failed to remove '$template_nix_path'" >&2
    else
         echo "Template file '$template_nix_path' not found, skipping removal."
    fi
    
    if [ -f "$template_json_path" ]; then
         echo "Removing template file '$template_json_path'"
         rm -f "$template_json_path" || echo "Warning: Failed to remove '$template_json_path'" >&2
    else
         echo "Template file '$template_json_path' not found, skipping removal."
    fi
    
    echo "Script finished."
  '';
}
