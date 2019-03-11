# GEOF Placard

The code for the [GEOF.io](https://geof.io) website.

A (generally) universal React app, “generally” because the client can’t currently request / render the docs HTML files. This is still `TODO`.

## Deployment

Placard expects all other GEOF modules to be present. It can’t be deployed in a vacuum because it runs `mix docs` for all of the Elixir components (and soon should also somehow host the docs for the JS components).

In addition, the following env variables need to be set:

- `FIREBASE_TOKEN` for deploying to Firebase
- `GCP_KEY` for uploading stuff to Google Cloud Storage
- `TWITTER_KEY` for tweeting an update on deploy (optional)
