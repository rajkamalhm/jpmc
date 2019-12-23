echo "Stopping RabbitMQ source(3.6), destination(3.7) & shovel management(3.x) containers..."
docker stop rabbit36 rabbit37 rabbit-shovel-node > /dev/null 2>&1
echo "Deleting RabbitMQ source(3.6), destination(3.7) & shovel management(3.x) containers..."
docker rm rabbit36 rabbit37 rabbit-shovel-node > /dev/null 2>&1
