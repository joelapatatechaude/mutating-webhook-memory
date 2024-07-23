#!/bin/sh

openssl req -x509 -newkey rsa:4096 -keyout test.key -out test.crt -days 365 -nodes -subj "/C=AU/ST=NSW/L=Sydney/O=redhat/OU=./CN=./emailAddress=."
