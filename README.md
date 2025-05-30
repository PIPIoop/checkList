# checkList
Краткий экскурс по установке и запуску дарта:
  1. Заходим и скачиваем zip архив https://docs.flutter.dev/get-started/install/windows/web - для запуска веб версии 
  2. Распаковывыем на какой то из дисков с путём /src/flutter
  3. Открываем windows powershell от имени администратора прописываем:  [Environment]::SetEnvironmentVariable("Path", $Env:Path + "; C:\src\flutter\bin", "User")
  4. В визуалку также закачиваем расширение flutter
  5. Перезагружаем визуалку
  6. В консоли прописываем:
                flutter doctor  проверяем все установки и выводим информацию, также устанавливаентся всё необходимое
                flutter config --enable-web  включаем web-отображение
                flutter devices отображает доступные устройства для отображения кода
                flutter create название  создает все файлы для запуска, после необходимо перейти в папку с файлом
                code . открывает все директории в визуалке (ну у меня там открылось)
  7. lib/main.dart — главный файл приложения.
     pubspec.yaml — зависимости.
     Папки android/, ios/, web/ и др. — под платформы.
  8.flutter run запускает flutter run -d Edge запускает в браузере
       
![image](https://github.com/user-attachments/assets/0573aae2-b675-472c-8174-9d861f36f3b9)
![image](https://github.com/user-attachments/assets/98623d85-309b-4ccd-8bb5-0450b6750a5b)


Итак окончательная версия и функционал:
Реализован красивый дизайн. А также существует функционал добавления, редактирования задач с их приоритетом от 1 до 3, от низкого до высокого приоритета соответственно. Также реализованна сортировка по приоритету, при появлении большого количества задач работает скрол вниз и вверх. Помиомо этого также работает свайп для удаление задачи. Реализованно уведомления о произошедшем на экране.
Пустой список
![image](https://github.com/user-attachments/assets/1865d771-15ad-4840-98bd-1624539f0186)
![image](https://github.com/user-attachments/assets/aa921cc2-0944-4ea3-9351-36b9b77e2a2b)
![image](https://github.com/user-attachments/assets/6d02f24c-5990-4116-a4f4-79bbb42d32c9)
![image](https://github.com/user-attachments/assets/f4c99fcd-6b3a-42c3-b9b9-9b339a52d395)
![image](https://github.com/user-attachments/assets/a80a6870-8566-4974-b03a-1c4f65b0e4d4)
