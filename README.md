Este projeto integra uma aplicação mobile desenvolvida em Flutter com um backend em Django para otimização de rotas utilizando a API do Google Maps. O sistema foi concebido para fornecer uma experiência simples e eficaz para usuários que desejam planejar rotas otimizadas a partir da localização atual do dispositivo até um destino fixo, passando por múltiplos pontos intermediários inseridos pelo usuário.

Frontend (Flutter)
Interface Simples e Intuitiva:
A aplicação apresenta uma tela limpa com campos para inserção de endereços. O usuário pode adicionar ou remover campos de forma dinâmica, mantendo sempre pelo menos um endereço para que a rota seja calculada.

Localização Atual como Origem:
Utilizando pacotes como geolocator e geocoding, o app captura a localização atual do dispositivo e a utiliza como ponto de partida para a rota.

Integração com o Google Maps:
Após a otimização dos endereços pelo backend, a aplicação abre o Google Maps com a rota completa, mostrando a melhor sequência de pontos (waypoints) que leva do ponto de origem até o destino fixo definido no backend.

Envio de Dados Estruturados:
Os endereços inseridos são enviados para o backend em formato JSON, juntamente com a localização atual, permitindo que a lógica de otimização seja aplicada de forma eficaz.
