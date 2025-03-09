start_dev:
  mix setup
  iex --dbg pry -S mix phx.server

start_prod:
  docker build -t vkr .
  docker run -p 4000:4000 --env-file=.prod.env -it vkr
