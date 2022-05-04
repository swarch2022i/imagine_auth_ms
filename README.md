# README

Para correr el proyecto correr los siguientes comandos:

docker-compose build

docker-compose up

docker-compose run web rake db:migrate

graphql

mutation {
  login(login: {
    username: "dacperezce",
    password: "12345678"
  }) {
    token,
    exp,
    username
  }
}

