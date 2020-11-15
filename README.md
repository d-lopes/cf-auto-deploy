# cf-auto-deploy

A Docker image to automate Cloud Foundry deployments

## Underlying software components

This alpine based docker image uses the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli) in version 7.1.0 to carry out deployments.

## Usage

`cf-auto-deploy` relies heavily on Cloud Foundry's ability to deploy app manifests. Please refer to the [Cloud Foundry Documentation](https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html) for further information.

In order to put this docker image to work, simply provide mandatory environment variables and mount your directories for local artifacts, manifests as well as stage-related variables.

Example:

```
CF_CLIENT_ID="<secret>"
CF_CLIENT_SECRET="<secret>"
CF_TOKEN_URL="https://your.idp-server.com/oauth/token"
CF_CREDENTIALS_URL="https://your.oauth2-client.com/cf/credentials/url"
CF_SPACE="sandbox"

docker run --rm \
  -v /local/path/to/artifacts:/tmp/artifacts \
  -v /local/path/to/manifests:/tmp/manifests \
  -v /local/path/to/stage-vars:/tmp/stage-vars \
  -e CF_CLIENT_ID="${CF_CLIENT_ID}" \
  -e CF_CLIENT_SECRET="${CF_CLIENT_SECRET}" \
  -e CF_TOKEN_URL="${CF_TOKEN_URL}" \
  -e CF_CREDENTIALS_URL="${CF_CREDENTIALS_URL}" \
  -e CF_SPACE="${CF_SPACE}" \
dl0pes/cf-auto-deploy:1.0.2

```

### Mandatory directorys

The following directories must be mounted when a docker container is started from this docker image:
* **/tmp/manifests**: directory with all the manifests. If you have multiple manifest files you can set a number as prefix so the files are processed in the desired order.
* **/tmp/stage-vars**: directory with YAML files containing stage dependent variables. There must be a file that corresponds to the `CF_SPACE` environment variable that you provide when starting the container. The file must be named `{CF_SPACE}.yml`.
* **/tmp/artifacts**: directory with all deployment artifacts. These are the files that are referenced from your manifests.

### Pre/Post-Processing Hooks

You can mount a directory with shell scripts for pre- and post-processing. Pre-processing scripts need to start with the prefix `pre-` and post-processing scripts with the prefix `post-`.

Example:

```
docker run --rm \
  -v /local/path/to/scripts:/tmp/scripts \
  ...
dl0pes/cf-auto-deploy:1.0.2

```

This command from above will automatically load your scripts and run them before and after the artifacts are deployed.

Please refer to the [examples](example-scripts) for two scripts which send slack notifications before and after the deployment process.

### Tasks

You can provide a comma-separated list of (task name):(task command) tupels. Example:

```
docker run --rm \
 ...
 -e APP_TASKS="sba-db-migrator:.java-buildpack/open_jdk_jre/bin/java de.dlopes.test.ExampleTask -k 256M -m 128M"
 ...
dl0pes/cf-auto-deploy:1.0.2

```

The task name needs to correspond with the name of your manifest file since these are matched based on their name. Once that tasks is matched to a manifest file, it will be automatically run after the artifact from the manifest has been successfully deployed.
