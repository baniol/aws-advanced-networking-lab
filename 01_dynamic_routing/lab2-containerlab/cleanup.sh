#!/bin/bash

echo "Destroying Containerlab topology..."
sudo containerlab destroy -t topology.yml

echo "Removing configuration files..."
rm -rf configs

echo "Lab cleanup complete!" 