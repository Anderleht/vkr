# Дипломный проект


Упрощённая версия инструмента похожего на webhook.site, разработанная на Elixir и Phoenix LiveView.

Данный инструмент позволяет пользователю легко исследовать HTTP запросы в реальном времени.

## Запуск в докере:
```
docker run -p 4000:4000 aschiavon/vkr
```


## Функции:

- Создание временных эндпоинтов для тестирования и мониторинга HTTP запросов.
- Исследование HTTP запросов в реальном времени, используя Phoenix LiveView.
- Хранение запросов в базе данных Sqlite для лёгкого анализа.

## Зависимости:
- Elixir
- Erlang
- Sqlite
- Docker
- Docker Compose

## Установка:

Для установки Elixir/Erlang используется [asdf](https://asdf-vm.com/).

После установки asdf, нужно использовать следующие команды для установки Elixir/Erlang:
```
# включите elixir/erlang плагины в asdf
asdf plugin add elixir
asdf plugin add erlang

# склонируйте репозиторий
git clone https://github.com/Anderleht/vkr && cd vkr

# установите зависимости из '.tool-versions' файла
asdf install
```

### Установка в режиме отладки:

```bash
mv .example.env.local .env.local

mix setup
```

или используя [just](https://github.com/casey/just)
```bash
just start_dev
```

## Использование

Перейдите по ссылке `http://localhost:4000/` и вас должно перенаправить на `http://localhost:4000/<session_id>`.

После этого, вы можете начать отправлять HTTP запросы на `http://<session_id>.localhost:4000/`, после чего вы начнёте видеть запросы.
