# IIIF Streamer

This is a proxy tool for streaming IIIF data from the nonpublic area of the
TextGrid Repository.

Status: Early Prototype

## Demo
[here](https://ci.de.dariah.eu/tg-iiif/manifests/textgrid:3q4gd.0/manifest.json)

## Dependencies
eXist-db, created with v4.7.0 - may works with earlier versions until 3.4.0.

## Build
`ant` creates a EXpath package in the `/build` directory.

`ant test` will load all dependencies and prepares a test env in the test
directory to be executed with `bash test/eXist-db-*/bin/startup.sh`

## Installation
Install in a eXist-db as you like.

Use a proxy in front and never ever let eXist run by a superior user, e.g. root!

## Configuration
In `confif.xml` add the Session ID to get access to the nonpublic area and
set the URL for the proxy according your setup.
