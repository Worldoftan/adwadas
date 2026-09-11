# Сборка IPA через GitHub Actions

1. Создай новый GitHub repository.
2. Загрузи содержимое этого проекта в repository.
3. Открой вкладку Actions.
4. Выбери `Build iOS IPA`.
5. Нажми `Run workflow`.
6. После завершения открой job и скачай artifact `VocabAssistant-IPA`.
7. Полученный `VocabAssistant-unsigned.ipa` можно импортировать в SideStore для подписи на iPhone.

Важно: workflow собирает unsigned IPA. Apple Developer сертификаты и приватные ключи в репозиторий не добавляются.
