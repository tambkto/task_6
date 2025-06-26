#!/bin/bash
exec > /var/log/user-data.log 2>&1

CLUSTER_NAME="${cluster_name}"
echo "ECS_CLUSTER=$CLUSTER_NAME" > /etc/ecs/ecs.config

