# No user-configurable parameters
# Accept additional arguments to this template corresponding to template
# parameter IDs
{ pkgs, agent_name ? "", google_cloud_project_id ? "", ... }: {
  # Shell script that produces the final environment
  bootstrap = ''
    cp -rf . "$out"  # Simplified the source to just '.'
    
    export AGENT_NAME="$WS_NAME"
    export WS_NAME="$WS_NAME-ws" # This line seems redundant with the one below, but keeping it based on original logic.
    
    # Set some permissions
    chmod -R +w "$out"
    
    # Create .env file with the parameter values
    cat > "$out/.env" << EOF
    AGENT_NAME=$AGENT_NAME  # Using the previously set AGENT_NAME
    GOOGLE_CLOUD_PROJECT=${google_cloud_project_id}
    WS_NAME=$WS_NAME  # Using the updated WS_NAME
    EOF
    
    # Remove the template files themselves and any connection to the template's
    # Git repository
    # Corrected paths to be relative to the copied content in "$out"
    rm -rf "$out/.git" "$out/idx-template".{nix,json}
  '';
}
