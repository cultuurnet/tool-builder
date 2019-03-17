# Tool builder

## Purpose

This repository contains a number of Rake tasks that aid in the creation of system
packages (.deb) of software for Ubuntu systems. These tools generally have no
pre-built Ubuntu packages available. The package building itself is left to the
excellent [fpm](https://fpm.readthedocs.io/en/latest/) tool.

Building system packages greatly simplifies and streamlines the infrastructure
(puppet, chef, ansible, ...) code to configure the systems that need the software.
Easy upgrades, dependency management, config file handling are all taken care of.

## Usage

You can just run `rake` to display all possible targets.

The tools each have the following targets available:
* download
* build
* build_package
* clean

You probably just need the `build_package` target, which also runs the other
tasks. For example, to build mysql-connector-java:
```ruby
rake mysql-connector-java:build_package
```
