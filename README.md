# Карапетян Артём Гарегинович, БПИ228, @kg_artem в телеграме для любых вопросов
**Вариант 21.** Задача о нелюдимых садовниках. Условие оставлю снизу.

![]([https://disk.yandex.ru/i/jQsJo9ANt3f1W](https://s22klg.storage.yandex.net/rdisk/462bc71f02b01631ae589110bd5f0859477496441329e0d7cfccd0607dbe235b/658228cb/fKqInKw3d7bLFOeFnMGnhAWcWBI65efizSzRUHDMLvFpCbFdksMcMK_LC_oBhJm7bN5NPUWSbyMugUzGP_05oivvhhN6RNtERwte9TzngnKr8npumZHI4midPdWhecNq?uid=0&filename=kandinsky-download-1702721904045.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=0&fsize=1689411&hid=fc9f22c84844f4aa62dce6cdfd026c75&media_type=image&tknv=v2&etag=2cbb6412eb51718c177c33b1d666f21e&rtoken=BpSb06rwaqmz&force_default=no&ycrid=na-14df73d2cd17af62062a0db7ec92ebe8-downloader3e&ts=60ce552f388c0&s=8133da98f77794c5b9664aeb49c8d3980dac8719138058331195362c9ae69725&pb=U2FsdGVkX18TBC0_yPNf2q9eMknCbuvUYJjh4ty5Gv40vVBVvXmRMxljhyC-fDN9xbOTRdtDtn_WjYNU2o8oWz2TmKChOC-Y6C0enKrzPk44Df_FYPw0Rj6XOPde4cpJ)g)

[Целевая программа](ihw4.cpp) и [уже собранный файл для запуска](ihw4)

[Альтернативное решение с состояниями на 9 баллов](ihw4_alternative.cpp) и [уже собранный файл для запуска](ihw4_alternative)

[Альтернативное решение на OpenMP на 10 баллов](ihw4_openmp.cpp) и [уже собранный файл для запуска](ihw4_openmp)

[Отдельный файл со всеми функциями для чтения аргументов](Helper.h)

### Хочу претендовать на 10 баллов. По критериям: ###

**Сценарий использования:**
Опишу его тут как можно подробнее, чтобы не расписывать в критериях очень подробно.
Идёт ввод вручную или из файла, это можно указать уже внутри программы (сначала он спрашивает, какой способ ввода вы хотите). Потом спрашивает, куда сохранять. Создаётся сад из указанных размеров и заполняется пустыми полями (я их обозначил как '-'), потом случайно генерируется от 10% до 30% камней или прудов (их я обозначил как 'o'). Далее запускаются два потока - два садовода, первый обозначен буквой 'F', второй обозначен буквой 'S'. Все вычисления параллельны кроме обработки поля: по условию задания только один садовод может обрабатывать поле в один момент. Плюс только один поток может выводить данные о саде на экран и в файл, но это сделано, чтобы два вывода не перекрыли друг друга. Когда заканчивает один из садоводов, общая булевая переменная это отслеживает, и второй садовод тоже заканчивает работу (на случай, когда скорость задана слишком низкой, не хочется ждать конца программы). Далее все в последний раз выводится в программу и заканчивается работа программы.

**4-5 баллов:** Все субъекты и сценарий максимально подробно описан выше. Садовники идут параллельно по оси времени, занимая разные позиции по осям X и Y, обрабатывая землю, если можно обработать. Модель вычислений тоже выше описана. Входные данные ограничены минимальным разумным пределом (я специально оставил возможность делать супер медленных садовников или супер большие сады, но отрицательные значения для размера сада или для скорости садовника задать никак нельзя). Реализовано приложение, решающее задачу. Ввод данных осуществляется с консоли и файла. Использован генератор случайных чисел для генерации камней и прудов в саду, их диапозон - от 10 до 30 процентов от общего размера сада. Вывод программы показывает сад на каждом шагу (сказано отразить все ключевые проеткающие события). В программе есть много комментариев.

**6-7 баллов:** Я подробно описал алгоритм. Генерация случайных чисел тоже есть и она уже описана. Ввод исходных данных можно организовать прямо с командной строки (с mac os терминала все работает!).

**8 баллов:** Добавлен вывода результата в файл, который задается пользователем в качестве параметра. Результаты программы выводятся на экран и в файл. Добавлен вариант ввода данных из файла. Можно выбрать: вручную или из файла. Есть три заготовленных файлика ввода и вывода (input1.txt, input2.txt, input3.txt, output1.txt, output2.txt, output3.txt), ввод данных из командной строки расширен.

**9 баллов:** Разработано альтернативное решение. Надо признать, у меня не такая сложная задача и кроме мьютекса для двух процессов ничего не надо, поэтому я просто использовал состояния для того, чтобы организовать эту мини-очередь садовников за обработкой квадрата. В целом, это никак не меняет работу программы, то есть работает она идентично и никаких издержек нет.

**10 баллов:** Разработано альтернативное решение на OpenMP. И оно всё так же идентично другим работает. Прямо точь-в-точь. Оффтоп: Сергей Александрович, вы спрашивали (ассистент, можете передать Сергею Александровичу, если есть желание) на паре, где и как вообще может пригодиться применение omp sections (потому что сами не знали), и там было всё неочевидно, и казалось, будто нигде. Но я использую секции для независимой обработки одного вектора с двух сторон. Вышло вполне уместно.

**Прошу заметить!** Я пользователь Mac OS (притом, несвежей версии), использовал VSCode для написания программ, собирал файл OpenMP вот такой вот формулой с кучей аргументов:
```
Запуск сборки…
/usr/bin/clang++ -std=gnu++14 -Xpreprocessor -fopenmp -I/usr/local/Cellar/libomp/17.0.6/include -L/usr/local/Cellar/libomp/17.0.6/lib -fcolor-diagnostics -fansi-escape-codes -g ihw4_openmp.cpp -o ihw4_openmp -lomp
```

Оставил еще для проверки уже собранные файлы, чтоб не пришлось компилировать (вдруг потребуется).

**Условие задачи**
Задача о нелюдимых садовниках. Имеется пустой участок зем- ли (двумерный массив размером M × N ) и план сада, разбитого на отдельные квадраты. От 10 до 30 процентов (задается случайно) площади сада заняты прудами или камнями. То есть недоступны для ухаживания. Эти квадраты располагаются на плане произволь- ным (случайным) образом. Ухаживание за садом выполняют два садовника, которые не хотят встречаться друг другом (то есть, од- новременно появляться в одном и том же квадрате). Первый садов- ник начинает работу с верхнего левого угла сада и перемещается слева направо, сделав ряд, он спускается вниз и идет в обратном направлении, пропуская обработанные участки. Второй садовник начинает работу с нижнего правого угла сада и перемещается снизу вверх, сделав ряд, он перемещается влево и также идет в обратную сторону. Если садовник видит, что участок сада уже обработан дру- гим садовником или является необрабатываемым, он идет дальше. Если по пути какой-то участок занят другим садовником, то садов- ник ожидает когда участок освободится, чтобы пройти дальше на доступный ему необработанный участок. Садовники должны ра- ботать одновременно со скоростями, определяемыми как пара- метры задачи. Прохождение через любой квадрат занимает неко- торое время, которое задается константой, меньшей чем времена обработки и принимается за единицу времени. Создать многопо- точное приложение, моделирующее работу садовников. Каждый садовник — это отдельный поток.
