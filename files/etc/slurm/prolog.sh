#!/usr/bin/env bash
set -e

logger -s -t slurm-prolog "START user=$SLURM_JOB_USER job=$SLURM_JOB_ID"
/etc/slurm/shared/bin/run-parts.sh /etc/slurm/prolog.d
logger -s -t slurm-prolog "END user=$SLURM_JOB_USER job=$SLURM_JOB_ID"
