#!/bin/bash
echo "* Creating a RabbitMQ 3.6 docker container (Source)..."
docker run -d --hostname rabbit36 --name rabbit36 -p 61234:15672 rabbitmq:3.6-management > /dev/null
sleep 2

echo "* Creating a RabbitMQ 3.7 docker container (Destination)..."
docker run -d --hostname rabbit37 --name rabbit37 -p 61235:15672 rabbitmq:3.7-management > /dev/null
sleep 2

echo "* Creating a latest RabbitMQ 3.x docker container (Shovel Management)..."
docker run -d --hostname rabbit-shovel-node --name rabbit-shovel-node -p 61236:15672 rabbitmq:3-management > /dev/null
sleep 2

echo "* Adding the DNS entries of source and destination containers in the shovel management container..."
sleep 2
declare -x rabbit36_ip=$(docker inspect rabbit36 | jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress')
declare -x rabbit37_ip=$(docker inspect rabbit37 | jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress')
declare -x rabbit_shovel_node_ip=$(docker inspect rabbit-shovel-node | jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress')
rabbit36_cmd="sh -c 'echo ${rabbit36_ip} rabbit36 >> /etc/hosts'"
rabbit37_cmd="sh -c 'echo ${rabbit37_ip} rabbit37 >> /etc/hosts'"
echo $rabbit36_cmd | xargs docker exec rabbit-shovel-node
echo $rabbit37_cmd | xargs docker exec rabbit-shovel-node

echo "* Enabling shovel and shovel management plugins in the shovel management container..."
sleep 20
docker exec rabbit-shovel-node sh -c 'rabbitmq-plugins enable rabbitmq_shovel rabbitmq_shovel_management'
sleep 2
