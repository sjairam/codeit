#!/bin/bash

kubectl rollout restart deployment acorn-server -n acorn

kubectl rollout restart deployment archecker -n archecker

kubectl  rollout restart deployment arclight -n arclight

kubectl rollout restart deployment curiosity -n curiosity

# DAIS

kubectl rollout restart deployment dims -n dais

kubectl rollout restart deployment dts -n dais

kubectl rollout restart deployment notifier -n dais

kubectl rollout restart deployment rabbitmq-email-notifier -n dais

kubectl rollout restart deployment transfer-service -n dais

# EDA

kubectl rollout restart deployment eda -n eda

kubectl rollout restart deployment eda-iip -n eda

