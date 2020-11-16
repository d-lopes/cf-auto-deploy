# Example Scripts

This directory contains two examples for pre- and post-processing scripts that send a slack notification to a webhook.

When spinning up the docker container, you can provide additional environment variables which will be available in these pre- and post-processing scripts:

```
docker run --rm \
  -v /local/path/to/scripts:/tmp/scripts \
 ...
 -e VERSION="2.6.9"
 -e USER="jenkins"
 ...
dl0pes/cf-auto-deploy:1.0.3

```
