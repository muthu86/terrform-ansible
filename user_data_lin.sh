#!/bin/bash
useradd vagrant
echo password | passwd ansible-user --stdin
