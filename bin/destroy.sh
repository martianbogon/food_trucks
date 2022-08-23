#!/usr/bin/env bash
#
# Convenience wrapper for terraform destroy. Will still ask for confirmation.

cd ../deploy
terraform destroy
