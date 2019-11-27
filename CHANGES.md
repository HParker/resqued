Starting with version 0.6.1, resqued uses semantic versioning to indicate incompatibilities between the master process, listener process, and configuration.

v0.9.0
------
* Avoid Errno::E2BIG on SIGHUP when there are lots of workers and lots of queues per worker. (#50) This changes the format of an env var that master passes to listener. Old and new versions won't crash, but they won't be able to communicate about currenly running workers.

v0.8.6
------
* Add compatibility for redis 4.0.

v0.8.5
------
* Accept a custom proc to create the worker object.

v0.8.4
------
* Use `Integer` in place of `Fixnum`, when it's available.

v0.8.3
------
* Add a "fast-exit" mode (#44)

v0.8.2
------
* Detach more completely (#43)
* Fix for ECONNRESET (#44)

v0.8.1
------
* Fix an error on fast SIGHUP (#42, @asceth)

v0.8.0
------

* Make proclines work again. (#40) (This introduces a new argument to the re-exec of resqued. Old masters (0.7.x) will be able to start new listeners (0.8.x), but new masters (0.8.x) will not be able to start <0.8 listeners.)

v0.7.14
-------

* Restart `SIGKILL`ed workers. (#39)

v0.7.13
-------

* Support for symlinks in production environments. (#36)

v0.7.12
-------

* Fix EXIT trap. (#34)
* Document resque compatibility. (#20)

v0.7.11
-------

* Show worker count in more proclines. (#32)

v0.7.10
-------

* Support require_relative in config files. (#31)

0.7.9
-----

* Add the app's current version to the procline. (#30)

0.7.8
-----

* Avoid losing track of workers (#21, #29)

0.7.7
-----

* Open source: set new gem home page, run CI on travis, etc.
* Rewrite Resqued::TestCase.

0.7.6
-----

* Adds more logging.

0.7.4
-----

* Better logging with (Mono)Logger!
* Unregister resqued's signal handlers before running a resque worker.
* Report the number of workers spinning down.

0.7.3
-----

broken

0.7.2
-----

* Ensure that no stale log file handles exists after a SIGHUP.

0.7.1
-----

* Adds some `assert_resqued` test helpers.

0.7.0
-----

* Configuration was changed. In a worker pool, you can no longer specify the number of workers in a bare argument, e.g. `queue "queue_name", "50%"`. Now, you must use a hash to define how many workers work on a given queue, e.g. `queue "queue_name", :percent => 50`. Additionally, you can provide several queues in one call to queue, e.g. `queue "a", "b", "c"`.

* A message was added to indicate that a listener has started. This lets the master wait until the new listener is fully booted before it kills the old listener.

* The master advertises its version to the listener. This will make it easier to update the protocol between the master and listener in a backward-compatible way.
