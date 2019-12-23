#!/bin/bash
rabbit_shovel_node_api="http://${rabbit_shovel_node_ip}:15672/api"
rabbit36_api="http://${rabbit36_ip}:15672/api"
rabbit37_api="http://${rabbit37_ip}:15672/api"

echo "* Creating source queue in RabbitMQ 3.6 instance..."
curl -s -u guest:guest -X PUT ${rabbit36_api}/queues/%2f/source_queue > /dev/null
sleep 2

echo "* Creating destination queue in RabbitMQ 3.7 instance..."
curl -s -u guest:guest -X PUT ${rabbit37_api}/queues/%2f/destination_queue > /dev/null
sleep 2

echo "* Publishing 500 messages to the source queue..."
for i in {1..500}
do
	curl -s -u guest:guest -X POST ${rabbit36_api}/exchanges/%2f/amq.default/publish -d '{"properties":{},"routing_key":"source_queue","payload":"Sample Message","payload_encoding":"string"}' > /dev/null
done

echo "* Getting couple of messages from the source queue..."
sleep 2
curl -s -u guest:guest -X POST ${rabbit36_api}/queues/%2f/source_queue/get -d '{"count":2,"requeue":"true","encoding":"auto","truncate":50000}' | jq '.'
sleep 2

echo "* Getting couple of messages from the destination queue (Output should be empty since the shovel is not yet created)..."
curl -s -u guest:guest -X POST ${rabbit37_api}/queues/%2f/destination_queue/get -d '{"count":2,"ackmode":"ack_requeue_true","encoding":"auto","truncate":50000}' | jq '.'
sleep 2

echo "* Creating the shovel user..."
curl -s -u guest:guest -X PUT ${rabbit_shovel_node_api}/users/shoveluser -d '{"password":"password","tags":"administrator"}' > /dev/null
sleep 2

echo "* Assigning permissions to shovel user..."
curl -s -u guest:guest -X PUT ${rabbit_shovel_node_api}/permissions/%2f/shoveluser -d '{"configure":".*","write":".*","read":".*"}' > /dev/null
sleep 5

echo "* Creating the shovel..."
curl -s -u shoveluser:password -X PUT ${rabbit_shovel_node_api}/parameters/shovel/%2f/my-shovel -d '{"value":{"src-uri":"amqp://rabbit36","src-queue":"source_queue","dest-uri":"amqp://rabbit37","dest-queue":"destination_queue"}}'
sleep 7

echo "* Getting the status of the shovel..."
sleep 5
curl -s -u shoveluser:password -X GET ${rabbit_shovel_node_api}/shovels | jq '.'

echo "* Getting couple of messages from the source queue (Output should be empty since the messages were migrated)..."
curl -s -u guest:guest -X POST ${rabbit36_api}/queues/%2f/source_queue/get -d '{"count":2,"requeue":"true","encoding":"auto","truncate":50000}' | jq '.'
sleep 2

echo "* Getting couple of messages from the destination queue..."
sleep 2
curl -s -u guest:guest -X POST ${rabbit37_api}/queues/%2f/destination_queue/get -d '{"count":2,"ackmode":"ack_requeue_true","encoding":"auto","truncate":50000}' | jq '.'
