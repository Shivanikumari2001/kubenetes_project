docker build -t wrakash/sky-service1:1.0.0 ./service1
docker push wrakash/sky-service1:1.0.0

docker build -t wrakash/sky-service2:1.0.0 ./service2
docker push wrakash/sky-service2:1.0.0

docker build -t wrakash/sky-gateway:1.0.0 ./api-gateway
docker push wrakash/sky-gateway:1.0.0