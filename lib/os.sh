#
# dotfiles/lib/os.sh
#
# Contains various functions for identifying the system's OS.
#
# Author: Luis Love
#

# Supported OS
declare -r OS_MACOS_NAME="macOS"
declare -r OS_UBUNTU_NAME="ubuntu"
declare -r OS_DEBIAN_NAME="debian"


_OSInfo() {
    local macVersion=""
    local output=""

    case "$OSTYPE" in
        darwin*) # OS is macOS
            macVersion="$(sw_vers -productVersion 2> /dev/null)"
            output="${OS_MACOS_NAME}_${OS_MACOS_NAME}_${OS_MACOS_NAME} ${macVersion}_${macVersion}"
            ;;
        linux*) # OS is some Linux Distro
            output="$(
                        [[ ! -f /etc/os-release ]] && exit 1
                        source /etc/os-release
                        echo "${ID}_${ID_LIKE}_${PRETTY_NAME}_${VERSION_ID}_${VERSION_CODENAME}"
                    )"
            [[ "$?" -ne 0 ]] && return 1
            ;;
        *) # Unknown OS
            return 1
            ;;
    esac

    echo "$output"
    return 0
}


OSInfo() {
    local id=""
    local idLike=""
    local prettyName=""
    local version=""
    local codename=""
    local unknown="____"

    IFS="_" read id idLike prettyName version codename <<< "$(_OSInfo 2> /dev/null)"

    [[ -z "$id" ]] && id="$unknown"
    [[ -z "$idLike" ]] && idLike="$unknown"
    [[ -z "$prettyName" ]] && prettyName="$unknown"
    [[ -z "$version" ]] && version="$unknown"
    [[ -z "$codename" ]] && codename="$unknown"

    echo "ID:          $id"
    echo "ID Like:     $idLike"
    echo "Description: $prettyName"
    echo "Version:     $version"
    echo "Codename:    $codename"
}


OSsupported() {
    local os=""
    local id=""
    local idLike=""
    local rest=""
    
    IFS="_" read id idLike rest <<< "$(_OSInfo 2> /dev/null)"

    for os in "$OS_MACOS_NAME" "$OS_UBUNTU_NAME" "$OS_DEBIAN_NAME"; do
        [[ "$os" == "$id" || "$os" == "$idLike" ]] && return 0 
    done

    return 1
}


OSName() {
    local id=""
    local idLike=""
    local prettyName=""
    local rest=""

    IFS="_" read id idLike prettyName rest <<< "$(_OSInfo 2> /dev/null)"

    if [[ ! -z "$prettyName" ]]; then
        echo "$prettyName"
        return 0
    fi

    return 1
}


OSType() {
    local id=""
    local idLike=""
    local rest=""

    IFS="_" read id idLike rest <<< "$(_OSInfo 2> /dev/null)"

    if [[ "$id" == "$OS_MACOS_NAME" || "$idLike" == "$OS_MACOS_NAME" ]]; then
        echo "$OS_MACOS_NAME"
        return 0
    elif [[ "$id" == "$OS_UBUNTU_NAME" || "$idLike" == "$OS_UBUNTU_NAME" ]]; then 
        echo "$OS_UBUNTU_NAME"
        return 0
    elif [[ "$id" == "$OS_DEBIAN_NAME" || "$idLike" == "$OS_DEBIAN_NAME" ]]; then
        echo "$OS_DEBIAN_NAME"
        return 0
    fi

    return 1
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
