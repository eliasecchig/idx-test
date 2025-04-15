
# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.11"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.python311Packages.uv
    pkgs.gnumake
  ];
  # Sets environment variables in the workspace
  env = {};
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "ms-toolsai.jupyter"
      "ms-python.python"
      "krish-r.vscode-toggle-terminal"
    ];
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = {
        create-venv = ''
        # Load environment variables from .env file if it exists
        source .env
          echo "Logging into gcloud..."
          echo "Please authenticate with Google Cloud by following the prompts."
          gcloud auth login --update-adc --brief --quiet

          echo "Setting gcloud project..."
          gcloud config set project $GOOGLE_CLOUD_PROJECT

          echo "Creating Python virtual environment and installing packages..."
          uv venv && uv pip install agent-starter-pack
          echo 'alias agent-starter-pack="~/$WS_NAME/.venv/bin/agent-starter-pack"' >> ~/.bashrc
          source ~/.bashrc

          echo "Running agent starter pack creation..."
          uv run agent-starter-pack create $AGENT_NAME
          exec bash
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
