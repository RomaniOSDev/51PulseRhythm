# Инструкция по добавлению виджета

## Шаги для добавления виджета в проект:

1. **Создать Widget Extension Target:**
   - В Xcode: File → New → Target
   - Выбрать "Widget Extension"
   - Назвать: "51PulseRhythmWidget"
   - Убедиться, что "Include Configuration Intent" НЕ отмечен (используем простой виджет)

2. **Добавить файлы:**
   - Скопировать `PulseRhythmWidget.swift` в Widget Extension target
   - Скопировать `SessionHistoryService.swift`, `ColorExtension.swift` и модели в Widget Extension target
   - Или создать shared framework для общих файлов

3. **Настроить URL Scheme в Info.plist основного приложения:**
   - Открыть Info.plist основного приложения
   - Добавить ключ `CFBundleURLTypes` (URL Types)
   - Добавить URL Scheme: `pulserhythm`
   - Это позволит виджету открывать приложение при нажатии

4. **Настроить App Groups (рекомендуется):**
   - Для обмена данными между приложением и виджетом использовать App Groups
   - В Capabilities добавить App Groups для обоих targets
   - Использовать один и тот же App Group ID для обоих

5. **Обновить SessionHistoryService для App Groups:**
   - Если используете App Groups, изменить UserDefaults на:
   ```swift
   UserDefaults(suiteName: "group.com.yourapp.pulserhythm")
   ```

6. **Минимальная версия iOS:**
   - Убедиться, что Widget Extension target поддерживает iOS 16.6+

## Примечания:
- Виджет обновляется автоматически через Timeline
- Для интерактивности используется App Intents (iOS 16+)
- Виджет может открывать приложение при нажатии
