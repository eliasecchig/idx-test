
# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-23.11"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.python311
    pkgs.python311Packages.pip
  ];
  # Sets environment variables in the workspace
  env = {};
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "ms-toolsai.jupyter"
      "ms-python.python"
    ];
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = {
        create-venv = ''
        # Install uv if you don't have it
        curl -LsSf https://astral.sh/uv/install.sh | sh
        
        source $HOME/.local/bin/env (sh, bash, zsh)
        
        # Install the Agent Starter Pack
        uv pip install agent-starter-pack
        agent-starter-pack create $WS_NAME
        '';
        # Open editors for the following files by default, if they exist:
        default.openFiles = [ ];
      };
      # To run something each time the workspace is (re)started, use the `onStart` hook
    };
    # Enable previews and customize configuration
    previews = {};
  };
}
