#!/bin/bash

echo "Stopping and removing containers..."
docker compose down

echo "Removing FRR configuration files..."
rm -rf frr-configs

echo "Lab cleanup complete!" 