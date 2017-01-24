# Dockerfile for Gravitational Teleport

This is a `Dockerfile` for running [Gravitational Teleport][1], an alternate SSH
server, within a Docker container.

The container is a work in progress and currently runs a pre-release version of
Teleport so that one can take advantage of the new [RABC functionality][2] that
is coming - this helps facilitate the use of OIDC in much better fashion than
currently released Teleport releases and helps with configuration management.
With that said, use at your own risk!

[1]: https://gravitational.com/teleport/
[2]: https://github.com/gravitational/teleport/issues/620

## Using the Container

Since a lot of Teleport's capabilities are managed through the configuration
file, this image is light on environment variables (in other words, there are
currently not any). Instead, running the following configuration is recommended:

 * Use `--net=host` to ensure that your ports are running on their respective
   well-known ports.
 * Share your YAML configuration to `/etc/teleport.yaml`, or roll the config
   into an image based off of this one.
 * Share your `/var/lib/teleport` directory, or use a named volume, to ensure
   that data is not lost when the container is deleted. The `Dockerfile` adds
   this directory as a volume.
 * Roles can also be put into an /etc/teleport.roles.d/ directory within the
   container. The image's entry point script checks this directory for any roles
   on container start and any `.yaml` files found in this directory are added to
   the server with `tctl upsert -f /etc/teleport.roles.d/ROLE.yaml`.

An example:

```
docker run --net=host --rm --volume /etc/teleport.yaml:/etc/teleport.yaml \
  --volume /var/lib/teleport:/var/lib/teleport \
  --volume /etc/teleport.roles.d:/etc/teleport.roles.d \
  vancluever/gravitational_teleport:latest
```

## Runtime Flags

To facilitate the use of this Docker image on servers that don't require much
configuration (namely SSH nodes), we allow extra options supplied as run
commands. See [the Configuration section of the Admin Manual][3] for more
details.

[3]: http://gravitational.com/teleport/docs/admin-guide/#configuration

Example:

```
docker run --net=host --rm --volume /var/lib/teleport:/var/lib/teleport \
  gravitational_teleport:latest --roles node \
  --auth-server auth.teleport.internal --token REG_TOKEN --labels web
```

Note that this method may expose sensitive information, so be careful! You may
just wish to use a configuration file instead.

Note the image's entrypoint script runs `/usr/local/bin/teleport start`, so
structure your command off of that.
