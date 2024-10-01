#!/bin/bash
set -e

UNAME=$(uname -s)

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
    pip install uv
  fi
  
  if [ "$UNAME" = "Darwin" ]; then
    echo "Installing uv on Darwin"
    brew install uv
  fi
  
  uv venv --python=3.10
  source "$VENV_NAME/bin/activate"
  echo "Virtual environment activated: $VENV_NAME"
  
  echo "Installing dependencies from requirements.txt..."
  uv pip install -r requirements.txt
  echo "Dependencies installation complete."
fi

PYTHON_LIB_PATH=$(find .venv/lib -type d -name "python3.*" -print -quit)
CV2_UTILS_PATH="$PYTHON_LIB_PATH/site-packages/cv2"
python3 -m PyInstaller --onefile --hidden-import="googleapiclient" --add-data "$CV2_UTILS_PATH:cv2" src/main.py
tar -czvf dist/archive.tar.gz dist/main
