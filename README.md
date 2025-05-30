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
