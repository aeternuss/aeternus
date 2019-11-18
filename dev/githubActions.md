# GitHub Actions

GitHub Actions features a powerful execution environment integrated into every step of your workflow.

## Workflow

Workflows are custom automated processes that you can set up in your repository
to build, test, package, release, or deploy any project on GitHub.

You must store workflows in the `.github/workflows` directory in the root of your repository.

### Syntax

YAML syntax for workflows:

* name
* on
* on.<event_name>.types
* on.<push|pull_request>.<branches|tags>
* on.<push|pull_request>.paths
* on.schedule
* env
* jobs
* jobs.<job_id>
* jobs.<job_id>.if
* jobs.<job_id>.env
* jobs.<job_id>.name
* jobs.<job_id>.needs
* jobs.<job_id>.runs-on
* jobs.<job_id>.steps
* jobs.<job_id>.timeout-minutes
* jobs.<job_id>.strategy
* jobs.<job_id>.container
* jobs.<job_id>.services

## Action

Actions are the smallest portable building block of a workflow.

You can build `Docker container` and `JavaScript` actions.

Actions require a metadata file to define the inputs, outputs and main entrypoint for your action.

The metadata filename must be `action.yml`.

### Syntax

YAML syntax for GitHub Actions:

* name
* author
* description
* inputs
* outputs
* runs
* branding

## Caching & Artifacts

Artifacts and caching are similar because they provide the ability to store files on GitHub,
but each feature offers different use cases and cannot be used interchangeably.

* Use caching when you want to reuse files that don't change often between jobs or workflow runs.
* Use artifacts when you want to save files produced by a job to view after a workflow has ended.

### Using the cache action

The cache action will attempt to restore a cache based on the `key` you provide.

When the action finds a cache it restores the cached files to the `path` you configure.

Input parameters for the cache action:

* key: Required The key created when saving a cache and the key used to search for a cache.
* path: Required The file path on the runner to cache or restore.
* restore-keys: Optional An ordered list of alternative keys to use for finding the cache if no cache hit occurred for key.

Output parameters for the cache action

* cache-hit: Set to true for a cache hit, and set to false for a cache miss.

```yaml
- name: Using caching
  uses: actions/cache@v1
  with:
    path: <path>
    key: <the>-<caching>-<key>
    restore-keys: |
      <the>-<caching>-
      <the>-
```

### Persisting workflow data using artifacts

Artifacts allow you to persist data after a job has completed.

An artifact is a file or collection of files produced during a workflow run.

You can use artifacts to pass data between jobs in a workflow
or persist build and test output after a workflow run has ended.

GitHub provides two actions that you can use to upload and download build artifacts.

Files uploaded to a workflow run are archived using the .zip format.

* actions/upload-artifact
* actions/download-artifact

```yaml
- name: Upload or Download artifact
  uses: actions/(upload|download)-artifact@v1
    with:
      name: <name>
      path: <path>
```

## GitHub Action Budget

Status badges show whether a workflow is currently failing or passing.

```markdown
![Actions Status](https://github.com/<OWNER>/<REPOSITORY>/workflows/<WORKFLOW_NAME>/badge.svg)
```
