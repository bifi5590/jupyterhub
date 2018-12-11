#!/bin/sh -

chown root:root /var/lib/private
chmod 700 /var/lib/private

cd /srv/jupyterhub
jupyterhub -f /srv/jupyterhub/jupyterhub_config.py