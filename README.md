# Building, Testing and Releasing for Multiple Platforms
Template illustrating the use of matrix builds and Go's ability to easily target multiple arch / platforms.
In this example you will learn about resources for verifying your software across multiple platforms and
architectures concurrently, how to properly inject version information into Go binaries via a release
workflow, and how to create an automated release with artifacts spanning multiple platforms and architectures.

## Getting Started
This is a GitHub template repo, so when you click "Use this template", it will create a new copy of this 
template in your org or personal repo of choice. Once you have created a repo from this template, you 
should be able to clone and navigate to the root of the repository.

### First Build
From the root of your repo, you should be able to run the following to build and test the Go action.
```shell script
$ make
$ ./bin/gophers version
```

### What's in Here?
A command line application which we will add some functionality.
```shell script
.
├── cmd
│   ├── add.go
│   ├── root.go
│   └── version.go
├── .github
│   └── workflows
│       ├── ci.yml
│       └── release.yml
├── .gitignore
├── go.mod
├── go.sum
├── LICENSE
├── main.go
├── Makefile
├── README.md
├── scripts
│   └── go_install.sh
└── xcobra
    ├── context.go
    ├── exit_handler.go
    └── noop_handler.go

```

#### [cmd](./cmd)
Contains the commands for the CLI application.

#### [.github/workflows/ci.yml](./.github/workflows/ci.yml)
Contains a continuous integration workflow which targets multiple platforms and multiple versions of Go
to create a matrix of machines which will be used to verify the application.

We'll also discuss how to optimize our builds through caching of module dependencies and other little 
tricks.

#### [.github/workflows/release.yml](./.github/workflows/release.yml)
Contains a release workflow which will show how to build release Go applications with a stamped version
for a variety of platforms and architectures. We'll also show how to reference a step in a workflow
to add artifacts to a release.

#### [main.go](./main.go)
It's the entrypoint for the CLI application.

#### [Makefile](./Makefile)
Contains a lot of the build foo. Generally, you shouldn't have to change this, but it wouldn't hurt 
to familiarize yourself with the contents.

#### [scripts](./scripts)
Contains a helper to install Go build tools in a tmp dir with an ephemeral Go module. This is nice
for when you want to install a build tool, but you don't want to dirty up your go.mod file.

#### [xcobra](./xcobra)
Contains some extra helpers Cobra helpers that make it easier to write responsive CLI applications and
easier to test too.

## Lab Video
TODO: record and post the first lab walking through this example

## Contributions
Always welcome! Please open a PR or an issue, and remember to follow the [Gopher Code of Conduct](https://www.gophercon.com/page/1475132/code-of-conduct).

