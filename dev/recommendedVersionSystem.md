# Recommended Versioning System

## Workflow

Recommend this workflow for projects:

- A `master` branch that the next release of your software is developed on
- Git `branches` for ongoing maintenance of each version of your software that is maintained
- Git `tags` for specific released versions that users might be using

We recommend release branches because it allows you to update them over time.
Git tags are static, so they are appropriate for specific versions that a user might have installed.

## Example

An example:

- master is your 1.2 release that isn't out yet
- 1.1.X is your release branch for the 1.1 version
- 1.1.1 is a similar tag of your 1.1 branch, with the latest release
- 1.1.0 is the first tag of your 1.1 branch

## Reference

- [An introduction to Sphinx and Read the Docs for Technical Writers](http://www.ericholscher.com/blog/2016/jul/1/sphinx-and-rtd-for-writers/)
