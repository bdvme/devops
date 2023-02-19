*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 10.01 Зачем и что нужно мониторить.

## Обязательные задания

1. Вас пригласили настроить мониторинг на проект. На онбординге вам рассказали, что проект представляет из себя
платформу для вычислений с выдачей текстовых отчетов, которые сохраняются на диск. Взаимодействие с платформой
осуществляется по протоколу http. Также вам отметили, что вычисления загружают ЦПУ. Какой минимальный набор метрик вы
выведите в мониторинг и почему?

2. Менеджер продукта посмотрев на ваши метрики сказал, что ему непонятно что такое RAM/inodes/CPUla. Также он сказал,
что хочет понимать, насколько мы выполняем свои обязанности перед клиентами и какое качество обслуживания. Что вы
можете ему предложить?

3. Вашей DevOps команде в этом году не выделили финансирование на построение системы сбора логов. Разработчики в свою
очередь хотят видеть все ошибки, которые выдают их приложения. Какое решение вы можете предпринять в этой ситуации,
чтобы разработчики получали ошибки приложения?

4. Вы, как опытный SRE, сделали мониторинг, куда вывели отображения выполнения SLA=99% по http кодам ответов.
Вычисляете этот параметр по следующей формуле: summ_2xx_requests/summ_all_requests. Данный параметр не поднимается выше
70%, но при этом в вашей системе нет кодов ответа 5xx и 4xx. Где у вас ошибка?
---
###### Ответы:

1. Вывел бы в мониторинг самые необходимые метрики:

   Метрики операционной системы:
   - количество доступной памяти в %
   - активность использования swap
   - количество доступных inode
   - свободное место на файловой системе в %

   Метрики вычислительных процессов:
   - CPU idle
   - CPU load average
   - RAM (резидентная, так как показывает сколько процесс потребляет физической памяти)
   - IOPS HDD
   - FileFd (открытые файловые дискрипторы)

   Метрики системных сервисов :
   - Latency — время на обработку одного запроса (с разделением на успешные и ошибочные запросы);
   - Traffic — количество запросов к компоненту (для веб-сервера это могут http-запросы, для базы данных — транзакции и т.п.);
   - Errors — количество ошибок;
   - Saturation — количественная метрика, отражающая, насколько компонент использует свои ресурсы и сколько у него «работы в очереди».

   Метрики сети:
   - входящая нагрузка
   - исходящая нагрузка
   - количество запросов по http, успешные (1xx, 2xx, 3xx) и неуспешные ответы (4xx, 5xx) веб-сервера.

2. Можно составить SLA соглашение с учетом ожиданий клиентов. SLO обозначить с учетом текущих измерений. И с помощью текущих измерений рассчитать SLI, так же можно предложить мониторить выполнение SLA (доступность приложения, время реакции на недоступность приложения, скорость восстановления работоспособности), вывести все это в систему мониторинга, например Grafana, в цвето-графическом виде, с указанием статуса метрики (зеленый - "OK", желтый - "есть проблемы", красный - "серьезная поломка").

3. Можно добавить в разрабатываемое ПО метрики нужные для отслеживания и использовать OpenSource стек мониторинга: Prometheus (для сбора метрик), Grafana (для визуализации собранной базы от Prometheus), Alertmanager (для отправки сообщений "Все упало" в Telegram). Стек развернуть в Docker.

4. В формуле не хватает учета ответов с 3хх кодами. Формула должна быть такой: $\frac{(\sum_{2xx}+\sum_{3xx})}{\sum_{all}}$