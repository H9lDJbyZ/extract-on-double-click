#!/bin/bash
ARCHIVE="$1"
FOLDER_NAME=$(basename "$ARCHIVE" | sed 's/\.[^.]*$//')
LOG_FILE="$HOME/.extract_log"
QUIET=0
[ "$2" = "--quiet" ] && QUIET=1
cd "$(dirname "$ARCHIVE")" || { echo "$(date): Ошибка: не удалось перейти в директорию $(dirname "$ARCHIVE")" >> "$LOG_FILE"; [ $QUIET -eq 0 ] && notify-send "Ошибка" "Не удалось открыть директорию"; exit 1; }

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
    echo "$(date): Архив $ARCHIVE содержит папку $FOLDER_NAME, распаковка в текущую директорию" >> "$LOG_FILE"
    if [ -d "$FOLDER_NAME" ]; then
        echo "$(date): Папка $FOLDER_NAME существует, вызываю zenity" >> "$LOG_FILE"
        zenity --question --text="Папка $FOLDER_NAME уже существует в текущей директории. Перезаписать?" || { echo "$(date): Пользователь отказался от перезаписи" >> "$LOG_FILE"; exit 0; }
        echo "$(date): Удаляю существующую папку $FOLDER_NAME" >> "$LOG_FILE"
        rm -rf "$FOLDER_NAME" || { echo "$(date): Ошибка удаления папки $FOLDER_NAME" >> "$LOG_FILE"; [ $QUIET -eq 0 ] && notify-send "Ошибка" "Не удалось удалить папку"; exit 1; }
    fi
    extract "" || { echo "$(date): Ошибка распаковки $ARCHIVE" >> "$LOG_FILE"; [ $QUIET -eq 0 ] && notify-send "Ошибка" "Не удалось распаковать $ARCHIVE"; exit 1; }
else
    echo "$(date): Проверка существования папки $FOLDER_NAME" >> "$LOG_FILE"
    if [ -d "$FOLDER_NAME" ]; then
        echo "$(date): Папка $FOLDER_NAME существует, вызываю zenity" >> "$LOG_FILE"
        zenity --question --text="Папка $FOLDER_NAME уже существует. Перезаписать?" || { echo "$(date): Пользователь отказался от перезаписи" >> "$LOG_FILE"; exit 0; }
        echo "$(date): Удаляю существующую папку $FOLDER_NAME" >> "$LOG_FILE"
        rm -rf "$FOLDER_NAME" || { echo "$(date): Ошибка удаления папки $FOLDER_NAME" >> "$LOG_FILE"; [ $QUIET -eq 0 ] && notify-send "Ошибка" "Не удалось удалить папку"; exit 1; }
    fi
    echo "$(date): Создаю новую папку $FOLDER_NAME" >> "$LOG_FILE"
    mkdir "$FOLDER_NAME" || { echo "$(date): Ошибка создания папки $FOLDER_NAME" >> "$LOG_FILE"; [ $QUIET -eq 0 ] && notify-send "Ошибка" "Не удалось создать папку"; exit 1; }
    extract "-C $FOLDER_NAME" || extract "-d $FOLDER_NAME" || extract "-o$FOLDER_NAME" || { echo "$(date): Ошибка распаковки $ARCHIVE в $FOLDER_NAME" >> "$LOG_FILE"; [ $QUIET -eq 0 ] && notify-send "Ошибка" "Не удалось распаковать $ARCHIVE"; exit 1; }
fi

[ $QUIET -eq 0 ] && notify-send "Распаковка завершена" "Архив $FOLDER_NAME успешно распакован