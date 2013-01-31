# Boxen

Manage Mac development boxes with love (and Puppet).

## Rules for Services

0. Run on a nonstandard port, usually default port + 1000 or 10000.

0. Install with a custom Boxen homebrew formula.

0. Suffix the Homebrew package's version, starting with `-boxen1`.

0. Run as a launchd service in the `dev` namespace, e.g.,
   `dev.dnsmasq`.

0. Store config, data, and log files in
   `$BOXEN_HOME/{config,data,log}. This will normally require
   customization of a service's Homebrew formula.

Sometimes it's not possible to follow these rules, but try hard.

## Hooks

0. All hooks must be in the namespace `Boxen::Hook::MyThing`.

0. All hooks must subclass from `Boxen::Hook::Base`

0. All hooks must provide an instance method `#enabled?`.

0. The `#enabled?` method must be based off of a `BOXEN_` prefixed env var.

0. All hooks must provide an instance method `#run`.

0. All hooks must be instantiable with 4 args: config, checkout, puppet, result.

## Contributing

Use the OS X system Ruby (1.8.7). Run `script/tests` often. Open PR's.
