#!/usr/bin/env bash
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

PACKAGE_ROOT="$(dirname "$SCRIPT_DIR")"

EMU_FOLDER="$PACKAGE_ROOT/.zhivax"

SHELL_PROMPT=" $ "

INITIAL_DIR=$(pwd)

trap '
    CLEANUP_TARGET="$INITIAL_DIR";
    if [ "$CLEANUP_TARGET" = "/root" ]; then
        CLEANUP_TARGET="/tmp";
    fi;

    if ! cd "$CLEANUP_TARGET" 2>/dev/null; then
        echo "Error: Permission denied: Cannot return to $CLEANUP_TARGET.";
        exit 1;
    fi
' EXIT

if [ ! -d "$EMU_FOLDER" ]; then
    mkdir -p "$EMU_FOLDER"
fi

EMU_PATH=$(cd "$EMU_FOLDER" && pwd)

cd "$EMU_FOLDER"

while true; do
    CURRENT_ABS_PATH=$(pwd)

    CURRENT_PATH=$(echo "$CURRENT_ABS_PATH" | sed "s|$EMU_PATH|~|")

    read -r -p "$CURRENT_PATH$SHELL_PROMPT" USER_COMMAND

    if [ "$USER_COMMAND" = 'exit' ]; then
        break
    fi

    TRIMMED_COMMAND=$(echo "$USER_COMMAND" | xargs)

    if [ "$TRIMMED_COMMAND" = 'cd' ]; then
        cd "$EMU_PATH"

    elif expr "$TRIMMED_COMMAND" : 'cd' >/dev/null; then

        PRE_CD_PATH=$(pwd)

        eval "$USER_COMMAND" 2>/dev/null

        case "$(pwd)" in
            "$EMU_PATH"* )
                ;;
            * )
                echo "Permission denied: Cannot leave emulator environment."
                cd "$PRE_CD_PATH"
                ;;
        esac

    else
        /usr/bin/env bash -c "$USER_COMMAND"
    fi
done
