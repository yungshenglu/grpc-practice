# Contributing

Thanks for contributing *grpc-practice*. The following steps are show how to contribute to *grpc-practice*. Please read the following content before contributing. Thanks for your cooperation.

## About Pull Requests

1. Fork this repository and clone the repository you forked.
    ```bash
    # Clone your fork of the repo into the current directory
    git clone https://github.com/<your-username>/grpc-practice
    # Navigate to the newly cloned directory
    cd <repo-name>
    ```
2. Create new branch named `develop` and switch to this branch
    ```bash
    # Create a new branch named develop
    $ git branch develop
    # Switch to branch named develop
    $ git checkout develop
    ```
3. Assign the original repository to a remote called `upstream` and update
    ```bash
    # Assign the original repo to a remote called "upstream"
    $ git remote add upstream https://github.com/yungshenglu/grpc-practice
    # Update to remote repository
    $ git remote update
    ```
4. Pull the latest version from our repository and merge to your branch
    ```bash
    # Pull the latest version from our repository
    $ git fetch upstream master
    # Merge our latest version to your branch
    $ git rebase upstream/master
    ```

---
## Contributor

In order to protect both you and ourselves, you will need to sign the [Contributor License Agreement](https://identity.linuxfoundation.org/projects/cncf).

* [David Lu](https://github.com/yungshenglu)

---
## License

ONOS (Open Network Operating System) is published under Apache License 2.0