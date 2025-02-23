#!/bin/bash

PUBLICPATH=$1
LOCALPATH=$2

# before a new batch is processed work, stage and project directory must be cleaned up

# 1. clear stage & work dir
cd ${PUBLICPATH}
rm -r stage/*
rm -r work/*

# clear project dir
cd ${LOCALPATH}
rm -r .nextflow*

