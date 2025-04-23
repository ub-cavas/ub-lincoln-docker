#!/bin/bash

docker build -t ubcavas/autoware-lincoln:0.43.1 -f autoware.dockerfile $@ . 