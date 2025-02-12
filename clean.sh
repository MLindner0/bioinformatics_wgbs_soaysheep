#!/bin/bash

# before a new batch is processed work, stage and project directory must be cleaned up

# 1. clear stage & work dir
cd /mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024/nextflow_pipeline/
rm -r stage/*
rm -r work/*

# clear project dir
cd /users/bi1ml/pipelines/next_wgbs
rm -r .nextflow*