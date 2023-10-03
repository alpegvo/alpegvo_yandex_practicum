**В проекте проанализированы данные о посещениях и покупках пользователей развлекательного приложения, привлеченных в период в период с 1 мая по 27 октября 2019 года, а также данные о затратах на рекламу в этот период времени.**

**Цель исследования:** выявить причину, по которой компания терпит убытки, несмотря на высокие рекламные расходы.

**Данные представлены тремя датасетами в формате `сsv`:**

**1. `visits_info_short.csv` - хранит лог сервера с информацией о посещениях сайта и имеет следующую структуру:**

`User Id` — уникальный идентификатор пользователя,

`Region` — страна пользователя,

`Device` — тип устройства пользователя,

`Channel` — идентификатор источника перехода,

`Session Start` — дата и время начала сессии,

`Session End` — дата и время окончания сессии.

**2. `orders_info_short.csv` - хранит информацию о заказах и содержит столбцы:**

`User Id` — уникальный идентификатор пользователя,

`Event Dt` — дата и время покупки,

`Revenue` — сумма заказа.

**3. `costs_info_short.csv` - содержит инфомацию о расходах на рекламу:**

`dt` — дата проведения рекламной кампании,

`Channel` — идентификатор рекламного источника,

`costs` — расходы на эту кампанию.