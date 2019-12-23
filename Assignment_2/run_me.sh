#!/bin/bash
source environment_setup.sh
source shovel.sh

echo
echo "----------------------------------------------------"
echo "Management UI can be accessed with the below links:"
echo "RabbitMQ 3.6 (Source) - http://${rabbit36_ip}:15672"
echo "RabbitMQ 3.7 (Destination) - http://${rabbit37_ip}:15672"
echo "RabbitMQ 3.x (Shovel management) - http://${rabbit_shovel_node_ip}:15672"
