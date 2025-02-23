#!/bin/bash
ARCHIVE="$1"
FOLDER_NAME=$(basename "$ARCHIVE" | sed 's/\.[^.]*$//')
LOG_FILE="$HOME/.extract_log"
QUIET=0
[ "$2" = "--quiet" ] && QUIET=1
cd "$(dirname "$ARCHIVE")" || { echo "Ошибка: не удалось перейти в директорию" >> "$LOG_FILE"; [ $QUIET -eq 0 ] && notify-send "Ошибка" "Не удалось открыть директорию"; exit 1; }

if [ ! -f "$ARCHIVE" ]; then
    echo "$(date): Ошибка: файл $ARCHIVE не найден" >> "$LOG_FILE"
    [ $QUIET -eq 0 ] && notify-send "Ошибка" "Файл $ARCHIVE не найден"
    exit 1
fi

check_archive_content() {
    case "$ARCHIVE" in
        *.tar.gz|*.tar|*.tar.bz2|*.tar.xz) tar -tf "$ARCHIVE" | head -n 1 | grep -q "^$FOLDER_NAME/" ;;
        *.zip) unzip -l "$ARCHIVE" | grep -q "^ *[0-9]* *[0-9-]* *[0-9:]* *$FOLDER_NAME/" ;;
        *.rar) unrar l "$ARCHIVE" | grep -q "^ *$FOLDER_NAME/" ;;
        *.7z) 7z l "$ARCHIVE" | grep -q "^ *[0-9-]* *[0-9:]* *D.... *$FOLDER_NAME/" ;;
        *) return 1 ;;
    esac
}

extract() {
    local dest="$1"
    case "$ARCHIVE" in
        *.tar.gz) tar -xzf "$ARCHIVE" $dest && return 0 ;;
        *.tar) tar -xf "$ARCHIVE" $dest && return 0 ;;
        *.tar.bz2) tar -xjf "$ARCHIVE" $dest && return 0 ;;
        *.tar.xz) tar -xJf "$ARCHIVE" $dest && return 0 ;;
        *.zip) unzip "$ARCHIVE" $dest && return 0 ;;
        *.rar) unrar x "$ARCHIVE" $dest && return 0 ;;
        *.7z) 7z x "$ARCHIVE" $dest && return 0 ;;
    esac
    return 1
}

if check_archive_content; then
    extract "" || { echo "$(date): Ошибка распаковки $ARCHIVE" >> "$LOG_FILE"; [ $QUIET -eq 0 ] && notify-send "Ошибка" "Не удалось распаковать $ARCHIVE"; exit 1; }
    FILES=$(ls -lh | tail -n +2 | awk '{print $9}')
else
    if [ -d "$FOLDER_NAME" ]; then
        zenity --question --text="Папка $FOLDER_NAME уже существует. Перезаписать?" || exit 0
        rm -rf "$FOLDER_NAME"
    fi
    mkdir "$FOLDER_NAME" || { echo "$(date): Ошибка создания папки $FOLDER_NAME" >> "$LOG_FILE"; [ $QUIET -eq 0 ] && notify-send "Ошибка" "Не удалось создать папку"; exit 1; }
    extract "-C $FOLDER_NAME" || extract "-d $FOLDER_NAME" || extract "-o$FOLDER_NAME" || { echo "$(date): Ошибка распаковки $ARCHIVE в $FOLDER_NAME" >> "$LOG_FILE"; [ $QUIET -eq 0 ] && notify-send "Ошибка" "Не удалось распаковать $ARCHIVE"; exit 1; }
    cd "$FOLDER_NAME"
    FILES=$(ls -lh | tail -n +2 | awk '{print $9}')
fi

[ $QUIET -eq 0 ] && notify-send "Распаковка завершена" "Содержимое $FOLDER_NAME:\n$FILES"