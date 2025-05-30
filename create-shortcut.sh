#!/bin/bash

# === Constants ===
SCRIPT_NAME="create-shortcut"
INSTALL_DIR="$HOME/.local/bin"
AUTOCOMP_DIR="$HOME/.local/share/bash-completion/completions"
BASHRC_FILE="$HOME/.bashrc"

# === Color output ===
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# === Default values ===
APPNAME=""
EXECPATH=""
ICONNAME=""
COMMENT=""
TERMINAL=false
CATEGORY=""
COPY_TO_DESKTOP=false
OVERWRITE=false

# === Functions ===

show_help() {
  echo -e "${BLUE}Usage:${RESET} $0 [options]"
  echo
  echo "Options:"
  echo "  -n, --name NAME            Application name (required)"
  echo "  -e, --exec PATH            Executable path or command"
  echo "  -i, --icon ICON            Icon name or icon path"
  echo "  -c, --comment TEXT         Description (optional)"
  echo "  -t, --terminal             Run in terminal (false by default)"
  echo "  -C, --category CATEGORY    App category (e.g., Utility)"
  echo "  -d, --desktop              Copy shortcut to Desktop"
  echo "  -f, --force                Overwrite existing shortcut"
  echo "  -I, --install              Install this script as a command"
  echo "  -h, --help                 Show this help"
  echo
}

install_man_and_info_pages() {
  echo -e "${BLUE}Installing man page...${RESET}"

  # Man page directory
  mkdir -p "$HOME/.local/share/man/man1"
  cat > "$HOME/.local/share/man/man1/create-shortcut.1" <<'EOF'
.TH create-shortcut 1 "May 2025" "User Commands"
.SH NAME
create-shortcut \- generate .desktop shortcuts for applications
.SH SYNOPSIS
.B create-shortcut
[\fIOPTIONS\fR]
.SH DESCRIPTION
\fBcreate-shortcut\fR helps users create .desktop files for launching apps from the system menu.
It supports interactive mode or CLI flags.

.SH OPTIONS
.TP
\fB\-n\fR, \fB\-\-name\fR
Application name.
.TP
\fB\-e\fR, \fB\-\-exec\fR
Command or executable path.
.TP
\fB\-i\fR, \fB\-\-icon\fR
Icon name or full image path.
.TP
\fB\-c\fR, \fB\-\-comment\fR
Short description.
.TP
\fB\-t\fR, \fB\-\-terminal\fR
Run the app in a terminal window.
.TP
\fB\-C\fR, \fB\-\-category\fR
App category (Utility, Graphics, etc.)
.TP
\fB\-d\fR, \fB\-\-desktop\fR
Also copy shortcut to Desktop.
.TP
\fB\-f\fR, \fB\-\-force\fR
Overwrite existing shortcut.
.TP
\fB\-I\fR, \fB\-\-install\fR
Install this script as a command.
.TP
\fB\-h\fR, \fB\-\-help\fR
Show help.

.SH EXAMPLES
.B create-shortcut
Runs in interactive mode.

.B create-shortcut --name Firefox --exec firefox --icon firefox --category Network

.SH FILES
~/.local/share/applications/

.SH AUTHOR
Created by you, customized for Arch Linux and beyond.

.SH SEE ALSO
.BR desktop-file-validate (1)
EOF

  gzip -f "$HOME/.local/share/man/man1/create-shortcut.1"
  echo -e "${GREEN}✔ Man page installed. Use 'man create-shortcut' after updating MANPATH.${RESET}"

  # Add to MANPATH if needed
  if ! grep -q "man" "$HOME/.bashrc"; then
    echo 'export MANPATH="$HOME/.local/share/man:$MANPATH"' >> "$HOME/.bashrc"
    echo -e "${YELLOW}ℹ️  Added MANPATH to ~/.bashrc (source it or restart).${RESET}"
  fi

  # Optional: Info page
  echo -e "${BLUE}Installing optional GNU info page...${RESET}"
  mkdir -p "$HOME/.local/share/info"
  cat > "$HOME/.local/share/info/create-shortcut.info" <<'EOF'
File: create-shortcut.info,  Node: Top

This is the documentation for the create-shortcut utility.

* Menu:

* Overview::
* Options::
* Examples::

* Overview::

  create-shortcut is a CLI and TUI script that helps you create
  .desktop launcher files on Linux for your favorite apps.

* Options::

  --name, -n         Application name
  --exec, -e         Executable path
  --icon, -i         Icon name or path
  --category, -C     Category (e.g. Utility, Network)
  --terminal, -t     Launch in terminal
  --desktop, -d      Copy shortcut to Desktop

* Examples::

  $ create-shortcut
  (interactive mode)

  $ create-shortcut --name Spotify --exec spotify --icon spotify --category AudioVideo

End of Info File
EOF

  echo -e "${GREEN}✔ Info page installed at ~/.local/share/info/create-shortcut.info${RESET}"
}


install_self() {
  echo -e "${BLUE}Installing script as '$SCRIPT_NAME'...${RESET}"
  mkdir -p "$INSTALL_DIR"
  cp "$0" "$INSTALL_DIR/$SCRIPT_NAME"
  chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

  if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}➕ Adding $INSTALL_DIR to PATH in $BASHRC_FILE${RESET}"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$BASHRC_FILE"
    source "$BASHRC_FILE"
  fi

  install_autocompletion
  install_man_and_info_pages

  echo -e "${GREEN}✅ Installed as command: create-shortcut${RESET}"
  echo -e "${BLUE}📘 You can now run: man create-shortcut${RESET}"
  exit 0
}


install_autocompletion() {
  DETECTED_SHELL=$(basename "$SHELL")

  echo -e "${BLUE}Configuring autocompletion for detected shell: $DETECTED_SHELL${RESET}"

  case "$DETECTED_SHELL" in
    bash)
      mkdir -p "$HOME/.local/share/bash-completion/completions"
      cat > "$HOME/.local/share/bash-completion/completions/create-shortcut" <<'EOF'
_create_shortcut_completions()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts="--name --exec --icon --comment --terminal --category --desktop --force --install --help"

  if [[ ${cur} == --category=* ]]; then
    COMPREPLY=( $(compgen -W "Utility Development Graphics Game AudioVideo Network Office System" -- "${cur#--category=}") )
    return 0
  fi

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0
}
complete -F _create_shortcut_completions create-shortcut
EOF
      if ! grep -q ".local/share/bash-completion/completions" "$HOME/.bashrc"; then
        echo "source ~/.local/share/bash-completion/completions/create-shortcut" >> "$HOME/.bashrc"
      fi
      echo -e "${GREEN}✔ Bash autocompletion installed. Restart or 'source ~/.bashrc'${RESET}"
      ;;

    zsh)
      mkdir -p "$HOME/.zsh/completions"
      cat > "$HOME/.zsh/completions/_create-shortcut" <<'EOF'
#compdef create-shortcut

_arguments \
  '--name[Application name]' \
  '--exec[Executable path or command]' \
  '--icon[Icon name or path]' \
  '--comment[Description]' \
  '--terminal[Run in terminal]' \
  '--category[Category]: :(Utility Development Graphics Game AudioVideo Network Office System)' \
  '--desktop[Copy to desktop]' \
  '--force[Overwrite existing]' \
  '--install[Install the script as a command]' \
  '--help[Show help]'
EOF
      if ! grep -q "fpath+=(~/.zsh/completions)" "$HOME/.zshrc"; then
        echo "fpath+=('$HOME/.zsh/completions')" >> "$HOME/.zshrc"
        echo "autoload -Uz compinit && compinit" >> "$HOME/.zshrc"
      fi
      echo -e "${GREEN}✔ Zsh autocompletion installed. Restart or 'source ~/.zshrc'${RESET}"
      ;;

    fish)
      mkdir -p "$HOME/.config/fish/completions"
      cat > "$HOME/.config/fish/completions/create-shortcut.fish" <<'EOF'
complete -c create-shortcut -l name -d "Application name"
complete -c create-shortcut -l exec -d "Executable path or command"
complete -c create-shortcut -l icon -d "Icon name or path"
complete -c create-shortcut -l comment -d "Description"
complete -c create-shortcut -l terminal -d "Run in terminal"
complete -c create-shortcut -l category -d "Category" -a "Utility Development Graphics Game AudioVideo Network Office System"
complete -c create-shortcut -l desktop -d "Copy to desktop"
complete -c create-shortcut -l force -d "Overwrite existing"
complete -c create-shortcut -l install -d "Install script"
complete -c create-shortcut -l help -d "Show help"
EOF
      echo -e "${GREEN}✔ Fish autocompletion installed. Restart or open a new terminal.${RESET}"
      ;;

    *)
      echo -e "${YELLOW}⚠ Unsupported shell '$DETECTED_SHELL'. No autocompletion installed.${RESET}"
      ;;
  esac
}


prompt_if_empty() {
  local varname=$1
  local prompt=$2
  local value=${!varname}
  if [[ -z "$value" ]]; then
    read -rp "$prompt: " value
    eval "$varname=\"\$value\""
  fi
}

# === Argument Parsing ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--name) APPNAME="$2"; shift 2 ;;
    -e|--exec) EXECPATH="$2"; shift 2 ;;
    -i|--icon) ICONNAME="$2"; shift 2 ;;
    -c|--comment) COMMENT="$2"; shift 2 ;;
    -t|--terminal) TERMINAL=true; shift ;;
    -C|--category) CATEGORY="$2"; shift 2 ;;
    -d|--desktop) COPY_TO_DESKTOP=true; shift ;;
    -f|--force) OVERWRITE=true; shift ;;
    -I|--install) install_self ;;
    -h|--help) show_help; exit 0 ;;
    *) echo -e "${RED}Unknown option:$RESET $1"; show_help; exit 1 ;;
  esac
done

# === Interactive Mode ===
if [[ -z "$APPNAME" ]]; then
  echo -e "${YELLOW}Interactive mode:${RESET}"
  prompt_if_empty APPNAME "Application name"
  prompt_if_empty EXECPATH "Executable path or command"
  read -rp "Use icon from system theme? (y/N): " THEME_ICON
  if [[ "$THEME_ICON" =~ ^[Yy]$ ]]; then
    prompt_if_empty ICONNAME "Icon name (e.g., utilities-terminal)"
  else
    prompt_if_empty ICONNAME "Full icon path (.png/.svg)"
  fi
  read -rp "Description (optional): " COMMENT
  read -rp "Run in terminal? (y/N): " TERMINAL_YN
  [[ "$TERMINAL_YN" =~ ^[Yy]$ ]] && TERMINAL=true
  echo "Choose a category:"
  OPTIONS=("Utility" "Development" "Graphics" "Game" "AudioVideo" "Network" "Office" "System" "Custom")
  select opt in "${OPTIONS[@]}"; do
    if [[ "$opt" == "Custom" ]]; then
      read -rp "Custom category: " CATEGORY
      break
    elif [[ -n "$opt" ]]; then
      CATEGORY="$opt"
      break
    fi
  done
  read -rp "Copy to desktop? (y/N): " COPY
  [[ "$COPY" =~ ^[Yy]$ ]] && COPY_TO_DESKTOP=true
fi

# === Validation ===
if [[ -z "$APPNAME" || -z "$EXECPATH" ]]; then
  echo -e "${RED}❌ App name and executable are required.${RESET}"
  exit 1
fi

# Validate command or executable
if ! command -v "$EXECPATH" &>/dev/null && [[ ! -x "$EXECPATH" ]]; then
  echo -e "${YELLOW}⚠ Warning: '$EXECPATH' is not a valid executable.${RESET}"
fi

# Validate icon
if [[ ! "$ICONNAME" =~ ^[a-zA-Z0-9_-]+$ && ! -f "$ICONNAME" ]]; then
  echo -e "${YELLOW}⚠ Warning: Icon '$ICONNAME' not found or invalid.${RESET}"
fi

# === Create Desktop File ===
FILENAME="${APPNAME// /_}.desktop"
DEST="$HOME/.local/share/applications/$FILENAME"
mkdir -p "$(dirname "$DEST")"

if [[ -e "$DEST" && $OVERWRITE != true ]]; then
  echo -e "${RED}❌ File already exists:${RESET} $DEST"
  echo "Use --force to overwrite."
  exit 1
fi

cat > "$DEST" <<EOF
[Desktop Entry]
Name=$APPNAME
Comment=$COMMENT
Exec=$EXECPATH
Icon=$ICONNAME
Terminal=$TERMINAL
Type=Application
Categories=$CATEGORY;
StartupNotify=true
EOF

chmod +x "$DEST"
echo -e "${GREEN}✅ Shortcut created:${RESET} $DEST"

if $COPY_TO_DESKTOP; then
  cp "$DEST" "$HOME/Desktop/"
  chmod +x "$HOME/Desktop/$FILENAME"
  echo -e "${GREEN}📁 Copied to Desktop:${RESET} ~/Desktop/$FILENAME"
fi

