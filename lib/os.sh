#
# dotfiles/lib/os.sh
#
# Contains various functions for identifying the system's OS.
#
# Author: Luis Love
#

# Ubuntu Supported
declare -r UBUNTU_NAME="ubuntu"
declare -r SUPPORTED_UBUNTU="Ubuntu"

# macOS Supported
declare -r MACOS_NAME="macOS"
declare -r SUPPORTED_MACOS="$MACOS_NAME"

# Unknown OS Criteria
declare -r UNKNOWN_OS="(unknownOS)"
declare -r UNKNOWN_OS_VERS="(unknownVersion)"
declare -r UNKNOWN_OS_SUPPORT="(unknownSupport)"

# OS Classifications
declare -r OS_TYPE_MACOS="$MACOS_NAME"
declare -r OS_TYPE_LINUX="linux"
declare -r OS_TYPE_UNKNOWN="$UNKNOWN_OS"


_OSInfo() {
    local os=""
    local version=""
    local support=""

    case "$OSTYPE" in
        darwin*) # OS is macOS
                os="$MACOS_NAME"
                version="$(sw_vers -productVersion 2> /dev/null)"
                ;;
        linux*) # OS is some Linux Distro
                IFS=" " read os version support <<< "$(lsb_release -sd 2> /dev/null)"
                ;;
        *) # Unknown OS
                ;;
    esac

    [[ "$os" == "" ]] && os="$UNKNOWN_OS"
    [[ "$version" == "" ]] && version="$UNKNOWN_OS_VERS"
    [[ "$support" == "" ]] && support="$UNKNOWN_OS_SUPPORT"

    echo "${os}_${version}_${support}"
}


OSsupported() {
    local os=""
    local version=""
    local support=""

    IFS="_" read os version support <<< "$(_OSInfo 2> /dev/null)"

    case "$os" in
        "$SUPPORTED_MACOS")
            return 0
            ;;
        "$SUPPORTED_UBUNTU")
            return 0
            ;;
        *)  # Invalid OS
            ;;
    esac

    return 1
}


OSName() {
    local os=""
    local version=""
    local support=""

    IFS="_" read os version support <<< "$(_OSInfo 2> /dev/null)"

    if OSsupported; then
        case "$os" in
            "$SUPPORTED_MACOS")
                echo "$MACOS_NAME"
                return 0
                ;;
            "$SUPPORTED_UBUNTU")
                echo "$UBUNTU_NAME"
                return 0
                ;;
            *)  # Invalid OS, shouldn't get to this case
                ;;
        esac    
    fi

    echo "$os"
}


OSType() {
    local os=""

    case "$OSTYPE" in
        darwin*) # OS is macOS
                os="$OS_TYPE_MACOS"
                ;;
        linux*) # OS is some Linux Distro
                os="$OS_TYPE_LINUX"
                ;;
        *) # Unknown OS
                os="$OS_TYPE_UNKNOWN"
                ;;
    esac 

    echo "$os"
}


# _validOSVersion() {
#     local minVer=$1
#     local curVer=$2
#     local -i mv_head=0
#     local -i cv_head=0

#     if [[ ! "$curVer" =~ ^[0-9\.]+$ ]]; then 
#         return 1
#     fi

#     while ! ([[ -z "$curVer" && -z "$minVer" ]]); do

#         if [[ -z "$minVer" ]]; then
#             mv_head="0"
#         else
#             mv_head=${minVer%%.*}
#             minVer=${minVer#"${mv_head}"}
#             ((mv_head = 10#$mv_head))
#             if [[ "$minVer" =~ ^\..* ]]; then
#                 minVer=${minVer#.} 
#                 [[ "$minVer" =~ ^\..* ]] && minVer="0$minVer"                
#             fi
#         fi

#         if [[ -z "$curVer" ]]; then
#             cv_head="0"
#         else
#             cv_head=${curVer%%.*}
#             curVer=${curVer#"${cv_head}"}
#             ((cv_head = 10#$cv_head))
#             if [[ "$curVer" =~ ^\..* ]]; then 
#                 curVer=${curVer#.} 
#                 [[ "$curVer" =~ ^\..* ]] && curVer="0$curVer"
#             fi
#         fi
        
#         [[ "$cv_head" -gt "$mv_head" ]] && return 0
#         [[ "$cv_head" -lt "$mv_head" ]] && return 1
#     done

#     return 0
# }
