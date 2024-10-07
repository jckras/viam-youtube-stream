#!/bin/bash
set -e

UNAME=$(uname -s)
# echo "OSTYPE is: $OSTYPE"

VENV_NAME=".venv"
echo "Current Directory: $(pwd)"
echo "Checking for virtual environment folder..."

if [ -d "$VENV_NAME" ]; then
  echo "Virtual environment found, activating..."
  source "$VENV_NAME/bin/activate"

  # Check if 'uv' can be imported in Python
  if ! python3 -c "import uv" > /dev/null 2>&1; then
    echo "'uv' not found in virtual environment. Recreating the virtual environment..."
    deactivate
    rm -rf "$VENV_NAME"
  else
    echo "'uv' is installed, skipping recreation of virtual environment."
  fi
fi

# Create a new virtual environment if it doesn't exist or was removed
if [ ! -d "$VENV_NAME" ]; then
  echo "Setting up virtual environment..."
  
if [ "$UNAME" = "Linux" ]; then
   echo "Installing uv on Linux"
    # Check if pip is installed
    if ! command -v pip &> /dev/null; then
      echo "'pip' not found. Installing pip..."
      sudo apt-get update && sudo apt-get install -y python3-pip

    fi
    pip install uv
  fi
  
if [ "$UNAME" = "Darwin" ]; then
    echo "Installing uv on Darwin" 
    # brew install uv
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.cargo/env
fi

uv venv --python=3.10
source .venv/bin/activate
  
echo "Installing dependencies from requirements.txt..."
uv pip install --upgrade pip
uv pip install -r requirements.txt
echo "Dependencies installation complete."

PYTHON_LIB_PATH=$(find .venv/lib -type d -name "python3.*" -print -quit)
CV2_UTILS_PATH="$PYTHON_LIB_PATH/site-packages/cv2"
python3 -m PyInstaller --onefile --hidden-import="googleapiclient" --add-data "$CV2_UTILS_PATH:cv2" src/main.py
tar -czvf dist/archive.tar.gz dist/main
