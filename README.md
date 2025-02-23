# Настройка скрипта для распаковки архивов по двойному клику

Этот скрипт позволяет распаковывать архивы в Elementary OS по двойному клику. Если внутри архива уже есть папка с таким же именем, содержимое извлекается в текущую директорию. В противном случае создаётся новая папка с именем архива.

## Требования
Перед началом убедитесь, что установлены следующие зависимости:
```bash
sudo apt update
sudo apt install tar unzip unrar p7zip-full libnotify-bin zenity
```

- `tar` — для `.tar`, `.tar.gz`, `.tar.bz2`, `.tar.xz`
- `unzip` — для `.zip`
- `unrar` — для `.rar`
- `p7zip-full` — для `.7z`
- `libnotify-bin` — для уведомлений
- `zenity` — для диалогов (опционально)

## Файлы
- `extract-on-double-click.sh` — основной скрипт для распаковки.
- `extract-on-double-click.desktop` — файл для интеграции с системой.
- `mimeapps.list` — настройки ассоциаций типов файлов (будет добавлен в существующий файл).

## Инструкция по установке

### 1. Размещение скрипта
1. Переместите файл `extract-on-double-click.sh` в директорию `~/.local/bin/`:
   ```bash
   mkdir -p ~/.local/bin
   cp extract-on-double-click.sh ~/.local/bin/
   ```
2. Сделайте скрипт исполняемым:
   ```bash
   chmod +x ~/.local/bin/extract-on-double-click.sh
   ```

### 2. Настройка .desktop файла
1. Переместите файл `extract-on-double-click.desktop` в директорию `~/.local/share/applications/`:
   ```bash
   mkdir -p ~/.local/share/applications
   cp extract-on-double-click.desktop ~/.local/share/applications/
   ```
2. Откройте файл и замените `/home/ВАШ_ПОЛЬЗОВАТЕЛЬ/` на ваш реальный путь к домашней директории (например, `/home/user/`):
   ```bash
   nano ~/.local/share/applications/extract-on-double-click.desktop
   ```
   Пример строки:
   ```
   Exec=/home/user/.local/bin/extract-on-double-click.sh %F
   ```
   Сохраните изменения (Ctrl+O, Enter, Ctrl+X).

3. Обновите базу данных приложений:
   ```bash
   update-desktop-database ~/.local/share/applications
   ```

### 3. Настройка MIME-типов
1. Проверьте, существует ли файл `~/.config/mimeapps.list`. Если нет, создайте его:
   ```bash
   mkdir -p ~/.config
   touch ~/.config/mimeapps.list
   ```
2. Откройте существующий `mimeapps.list` для редактирования:
   ```bash
   nano ~/.config/mimeapps.list
   ```
3. Добавьте или замените секцию `[Default Applications]` содержимым из предоставленного `mimeapps.list`:
   ```
   [Default Applications]
   application/zip=extract-on-double-click.desktop
   application/x-tar=extract-on-double-click.desktop
   application/x-rar=extract-on-double-click.desktop
   application/x-7z-compressed=extract-on-double-click.desktop
   ```
   Сохраните изменения (Ctrl+O, Enter, Ctrl+X).

### 4. Проверка
1. Найдите архив (например, `.zip`, `.tar.gz`, `.rar`, `.7z`) в файловом менеджере.
2. Дважды кликните по нему.
   - Если внутри архива есть папка с его именем (например, `test/` в `test.zip`), содержимое извлечётся в текущую папку.
   - Если папки нет, создастся новая папка с именем архива (например, `test`), и содержимое будет распаковано туда.

## Устранение неполадок
- **Скрипт не запускается**: Проверьте права на выполнение (`chmod +x ~/.local/bin/extract-on-double-click.sh`) и наличие зависимостей.
- **Двойной клик не работает**: Убедитесь, что `.desktop` файл правильно настроен и MIME-типы обновлены.
- **Ошибки в логах**: Проверьте `~/.extract_log` для диагностики.

## Дополнительно
- Для запуска без уведомлений используйте:
  ```bash
  ~/.local/bin/extract-on-double-click.sh архив.zip --quiet
  ```
- Если папка уже существует, появится диалог с вопросом о перезаписи (требуется `zenity`).

Готово! Теперь архивы будут распаковываться по двойному клику согласно заданной логике.