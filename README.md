# Deploy.sh

This is my idea of deployment. This is the way i normally deploy php applications (but it is probably useable for other languages as well) since several years in several big sized projects.
The idea is to have some kind of build process beforehand which produces a production tar.gz in the following format <appname>-<builddate>-<buildid>. Where buildid might be some arbitrary stuff. Jenkins build number, git commit. Whatever you like to make the build trackable (besides the date).

It then deploys to a folder which is structured like this:

``
current -> myapp-20141002123112-2/
myapp-20140929112140-1
myapp-20141002123112-2
``

Assuming you have a webserver configured to point somewhere in current like current/web it will allow version switching without any downtime or inconsistencies. A simple git pull and checkout for example would likely result in a broken application state during git operations. This script does an atomic swap of code bases.

It will also cleanup stale builds
