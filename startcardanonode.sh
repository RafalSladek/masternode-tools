#!/bin/bash
set -euo pipefail
coinuser=cardano
sudo -u "$coinuser" -H sh -c "export PATH=/home/$coinuser/.cargo/bin:$PATH && \
cd /home/$coinuser/jormungandr/scripts && \
jormungandr --genesis-block ./block-0.bin --config ./config.yaml --secret ./pool-secret1.yaml"
