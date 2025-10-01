#!/bin/bash

# Folder where the launchers must be stored
readonly TARGET_FOLDER="/usr/local/bin"

launcherName=()
# Indexed Array for launchers' names
launcherName[1]="idea"
launcherName[2]="pycharm"
launcherName[3]="webstorm"
launcherName[4]="phpstorm"
launcherName[5]="rider"
launcherName[6]="clion"
launcherName[7]="datagrip"
launcherName[8]="rubymine"
launcherName[9]="goland"
launcherName[10]="rustrover"

appName=()
# Indexed Array for applications' folder names at /Applications
appName[1]="IntelliJ IDEA.app"
appName[2]="PyCharm.app"
appName[3]="WebStorm.app"
appName[4]="PhpStorm.app"
appName[5]="Rider.app"
appName[6]="CLion.app"
appName[7]="DataGrip.app"
appName[8]="RubyMine.app"
appName[9]="GoLand.app"
appName[10]="RustRover.app"

menuItem=()
# Indexed Array for menu items
ideName[1]="IntelliJ IDEA"
ideName[2]="PyCharm"
ideName[3]="WebStorm"
ideName[4]="PhpStorm"
ideName[5]="Rider"
ideName[6]="CLion"
ideName[7]="DataGrip"
ideName[8]="RubyMine"
ideName[9]="GoLand"
ideName[10]="RustRover"

ideCount=${#ideName[@]}

# Define colors
readonly RED='\033[1;31m'
readonly GRAY='\033[0;37m'
readonly GREEN='\033[1;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# UI Components
readonly BANNER=$(cat <<'EOF'
          ╔═════════════════════════════════════════════╗
          ║      ██╗██████╗          ██████╗██╗     ██╗ ║
          ║      ██║██╔══██╗        ██╔════╝██║     ██║ ║
          ║      ██║██████╔╝        ██║     ██║     ██║ ║
          ║ ██   ██║██╔══██╗        ██║     ██║     ██║ ║
          ║ ╚█████╔╝██████╔╝███████╗╚██████╗███████╗██║ ║
          ║  ╚════╝ ╚═════╝ ╚══════╝ ╚═════╝╚══════╝╚═╝ ║
          ╚═════════════════════════════════════════════╝
EOF
)

# Admin permissions check
check_admin_privileges() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}╔════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ERROR: This script requires administrator rights  ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}>> Please run with sudo:${NC}"
        echo -e "${GREEN}   sudo $0${NC}"
        echo ""
        exit 1
    fi
}

display_banner() {
    echo -e "${RED}${BANNER}${NC}"
    echo -e "${YELLOW}               [ JET BRAINS COMMAND-LINE INTERFACE ]${NC}"
    echo ""
}

display_menu() {
    echo -e "${GRAY}                      ╔═════════════════════╗${NC}"

    for i in $(seq 1 ${#ideName[@]}); do
        printf "${GRAY}                      ║${NC} ${GREEN}%2d${NC}) %-16s${GRAY}║${NC}\n" "$i" "${ideName[$i]}"
    done

    echo -e "${GRAY}                      ║${NC} ${RED} 0${NC}) Exit Menu       ${GRAY}║${NC}"
    echo -e "${GRAY}                      ╚═════════════════════╝${NC}"
}

validate_input() {
    local input=$1

    if [[ ! "$input" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}>> Invalid input. Please enter a number.${NC}"
        return 1
    fi

    if (( input < 0 || input > ideCount )); then
        echo -e "${RED}>> Invalid selection. Choose between 0-${ideCount}.${NC}"
        return 1
    fi

    if (( choice == 0 )); then
        echo -e "${RED}>> Exiting JetBrains CLI...${NC}"
        exit
    fi

    return 0
}

implement_launcher() {
    local choice=$1
    local launcher_path="$TARGET_FOLDER/${launcherName[$choice]}"
    local app_name="${appName[$choice]}"

    echo -e "${GREEN}>> Doing stuff...${NC}"

    # Write launcher script
    cat > "$launcher_path" << 'SCRIPT_EOF'
#!/bin/sh

open -na "IDE_NAME_PLACEHOLDER" --args "$@"
SCRIPT_EOF

    # Replace the placeholder with actual IDE name
    sed -i '' "s|IDE_NAME_PLACEHOLDER|${app_name}|g" "$launcher_path"

    # Make the launcher script executable
    chmod +x "$launcher_path"
    echo -e "${GRAY}>> [✔] Operation complete.${NC}"
    echo -e "${GRAY}>> [✔] Launcher created at: ${launcher_path}${NC}"
}

main() {
    check_admin_privileges

    while true; do
        display_banner
        display_menu

        echo ""
        read -r -p "$(echo -e "${YELLOW}Select an option [0-${#ideName[@]}]: ${NC}")" choice < /dev/tty
        echo ""

        if validate_input "$choice"; then
            implement_launcher "$choice"
        fi

        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

main "$@"