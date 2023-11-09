# Wren:IDM System Test Resources

Resources for performing Wren:IDM system tests.


## Test Categories

* audit - _TODO_
* auth - _TODO_
* config - _TODO_
* crypto - _TODO_
* email - Email Service Features
* endpoint - Endpoint Features
* info - Info Service Features
* managed - _TODO_
* policy - _TODO_
* provisioner - Provisioner Features
* repo - _TODO_
* router - _TODO_
* scheduler - _TODO_
* scripting - _TODO_
* sync - Synchronization Features
* workflow - Workflow Features


## Running Tests

Tests can be run manually by executing shell scripts in alphabetical order in their
respective test category folder.

Use `run.sh` shell script to run the whole test suite:

```console
$ ./run.sh
```

Note that the whole test suite finishes successfully (without an error), the platform containers will be shutdown.
In case of a failed test, the platform won't be shutdown to allow for easier debugging.

Tests are based on docker image of Wren:IDM named `wrenidm`. This image name can be overriden
with `WRENIDM_IMAGE` environment variable:

```console
$ WRENIDM_IMAGE=wrenidm-local ./run.sh
```

Failed tests can be resumed from a specific category with `RESUME_FROM` environment variable
(be sure to cleanup leftover docker containers before resuming):

```console
$ RESUME_FROM=replication ./run.sh
```
