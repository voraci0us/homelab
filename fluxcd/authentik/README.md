[Blueprints](https://docs.goauthentik.io/customize/blueprints/) are used as a way to manage most Authentik resources declaratively, since no operator exists at time of writing.

These blueprints are tricky to write and debug. Suggested setting log level to debug - otherwise, no blueprint validation errors are shown in the web UI or pod logs. Also, reference the provided [JSON schema](https://goauthentik.io/blueprints/schema.json).

The blueprints perform all setup except for setting passwords on user accounts (service or otherwise).