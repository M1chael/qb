# Цитатник

Данный телеграм-бот создан для размещения цитат из книг А. Розова и ссылок на его посты в ЖЖ в канале ["Мегацитатник"](https://t.me/megaquotes) в Telegram.

### Зависимости

Установить зависимости sqlite3: `apt install sqlite3 libsqlite3-dev`

### Установка

```
bundle
```

## Тесты

```
rspec
```

## Настройка

### Файл конфигурации

Пример файла конфигурации (`assets/config.yml`):

```yaml
---
# Имя базы данных
:db: quotes.db
# Токен телеграм-бота
:telegram_token: 333333333:AABUi9j8LjG79r8YeoFoFs89
# Идентификатор канала
:chat_id: 123456789
# Путь к лог-файлу
:log: logs/bot.log
# Кнопка голосования
:vote: "✋️ Спасибо"
# Ссылка на RSS-ленту
:rss: 'https://domain.com/rss'

```

### Структура БД

```sql
# Авторы
CREATE TABLE authors (
id INTEGER PRIMARY KEY,
name STRING
);
#
# Книги
CREATE TABLE books (
id INTEGER PRIMARY KEY,
name STRING
);
#
# Сообщения
# eid - id из таблицы posts или quotes
# type - post или quote
CREATE TABLE messages (
mid INTEGER PRIMARY KEY,
eid INTEGER,
type STRING
);
#
# Голосование
# mid - mid сообщения из таблицы messages
# uid - идентификатор пользователя Telegram
CREATE TABLE feedback (
mid INTEGER,
uid INTEGER
);
#
# Ссылки на посты в ЖЖ
# score - количество поблагодаривших в Telegram
CREATE TABLE posts (
id INTEGER PRIMARY KEY,
link STRING,
score INTEGER
);
#
# Цитаты
# post_date - дата последнего поста с цитатой
# post_count - количество постов с цитатой
# score - количество поблагодаривших в Telegram
CREATE TABLE quotes (
id INTEGER PRIMARY KEY,
text STRING,
author INTEGER,
book INTEGER,
post_date INTEGER DEFAULT 0,
post_count INTEGER DEFAULT 0,
score INTEGER DEFAULT 0
);
```

## Использование

### poster.rb

Запускается с одним из обязательных параметров:
* -r, --rss - проверить наличие нового сообщения в RSS-ленте и отправить его в канал

  1. Запускается по расписанию, например, через cron: `11 * * * * /usr/bin/flock -n /tmp/postercron.lck /home/user/path/to/bin/poster.rb -r`
  2. Скачивает rss с сайта, чтобы узнать id крайней записи
  3. Если запись с этим id уже есть в БД, завершается
  4. Иначе отправляет сообщение в канал со ссылкой на крайнюю запись и сохраняет её id в БД
* -q, --quote - запостить случайную цитату в канал

  1. Запускается по расписанию, например, через cron: `11 11 * * * /usr/bin/flock -n /tmp/postercron.lck /home/user/path/to/bin/poster.rb -q`
  2. Выбирает случайную цитату из БД следующим образом:
    - в 20% случаев:
      - цитаты упорядочиваются по количеству постов в Telegram;
      - цитаты с одинаковым количеством постов перемешиваются случайным образом;
      - отбирается 30% от общего числа цитат в БД с наименьшим количеством постов;
      - отобранные цитаты сортируются по дате размещения в Telegram;
      - берётся самая старая из отобранных цитат;
    - в других 70% случаев:
      - цитаты упорядочиваются по дате;
      - берётся 30% самых старых цитат;
      - отобранные цитаты сортируются по количеству постов в Telegram;
      - если количество постов у цитат совпадает, они перемешиваются случайным образом;
      - берётся цитата с наименьшим количеством постов в Telegram;
    - в оставшихся 10% случаев цитата выбирается случайным образом.
  3. Отправляет цитату в канал и сохраняет её id в БД

Цитаты могут размещаться в канале повторно. Голосвать за каждую цитату можно только один раз при каждом размещении. Голоса, отданные через повторные сообщения, суммируются с полученными ранее.

### listener.rb

0. Запускается, например, с помощью monit:

`/etc/monit/conf.d/localhost`:
```
check process listener.rb
matching "listener.rb"
start program = "/bin/bash -c '/home/user/path/qb.sh'" as uid suer and gid group
stop program = "/bin/bash -c 'killall listener.rb
```

`/home/user/path/qb.sh`:
```
#!/bin/bash

. /home/user/path/export.sh
/home/user/path/to/bin/listener.rb &
```

`/home/user/path/export.sh`:
```
export PATH=/home/bq/.rvm/gems/ruby-2.4.0/bin:/home/bq/.rvm/gems/ruby-2.4.0@global/bin:/usr/share/rvm/rubies/ruby-2.4.0/bin:/usr/share/rvm/bin:/home/bq/bin:/home/bq/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
export GEM_HOME=/home/bq/.rvm/gems/ruby-2.4.0
export GEM_PATH=/home/bq/.rvm/gems/ruby-2.4.0:/home/bq/.rvm/gems/ruby-2.4.0@global
export MY_RUBY_HOME=/usr/share/rvm/rubies/ruby-2.4.0
export IRBRC=/usr/share/rvm/rubies/ruby-2.4.0/.irbrc
```

1. Слушает сообщения из Telegram
2. Учитывает результаты голосования в БД
3. Отправляет уведомления проголосовавшим пользователям
