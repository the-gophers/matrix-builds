
GOPATH  := $(shell go env GOPATH)
GOARCH  := $(shell go env GOARCH)
GOOS    := $(shell go env GOOS)
GOPROXY := $(shell go env GOPROXY)
ifeq ($(GOPROXY),)
GOPROXY := https://proxy.golang.org
endif
export GOPROXY

ROOT_DIR        :=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
APP             = gophers
PACKAGE  		= github.com/the-gophers/$(APP)
DATE    		?= $(shell date +%FT%T%z)
VERSION 		?= $(shell git rev-list -1 HEAD)
SHORT_VERSION 	?= $(shell git rev-parse --short HEAD)
GOBIN      		?= $(HOME)/go/bin
GOFMT   		= gofmt
GO      		= go
PKGS     		= $(or $(PKG),$(shell $(GO) list ./... | grep -vE "^$(PACKAGE)/templates/"))
TOOLSBIN		= $(ROOT_DIR)/tools/bin
GO_INSTALL		= $(ROOT_DIR)/scripts/go_install.sh

# Active module mode, as we use go modules to manage dependencies
export GO111MODULE=on

V = 0
Q = $(if $(filter 1,$V),,@)

.PHONY: all
all: fmt lint vet tidy build

## --------------------------------------
## Tooling Binaries
## --------------------------------------

GOLINT_VER := v1.31.0
GOLINT_BIN := golangci-lint
GOLINT := $(TOOLSBIN)/$(GOLINT_BIN)-$(GOLINT_VER)

$(GOLINT): ; $(info $(M) buiding $(GOLINT))
	GOBIN=$(TOOLSBIN) $(GO_INSTALL) github.com/golangci/golangci-lint/cmd/golangci-lint $(GOLINT_BIN) $(GOLINT_VER)

GOX_VER := v1.0.1
GOX_BIN := gox
GOX := $(TOOLSBIN)/$(GOX_BIN)-$(GOX_VER)

$(GOX): ; $(info $(M) buiding $(GOX))
	GOBIN=$(TOOLSBIN) $(GO_INSTALL) github.com/mitchellh/gox $(GOX_BIN) $(GOX_VER)

GOVERALLS_VER := v0.0.7
GOVERALLS_BIN := goveralls
GOVERALLS := $(TOOLSBIN)/$(GOVERALLS_BIN)-$(GOVERALLS_VER)

$(GOVERALLS): ; $(info $(M) buiding $(GOVERALLS))
	GOBIN=$(TOOLSBIN) $(GO_INSTALL) github.com/mattn/goveralls $(GOVERALLS_BIN) $(GOVERALLS_VER)


## --------------------------------------
## Build and related goals
## --------------------------------------

build: lint tidy ; $(info $(M) buiding ./bin/$(APP))
	$Q $(GO)  build -ldflags "-X $(PACKAGE)/cmd.GitCommit=$(VERSION)" -o ./bin/$(APP)

.PHONY: lint
lint: $(GOLINT) ; $(info $(M) running golint…) @ ## Run golint
	$(Q) $(GOLINT) run ./...

.PHONY: fmt
fmt: ; $(info $(M) running gofmt…) @ ## Run gofmt on all source files
	@ret=0 && for d in $$($(GO) list -f '{{.Dir}}' ./...); do \
		$(GOFMT) -l -w $$d/*.go || ret=$$? ; \
	 done ; exit $$ret

.PHONY: vet
vet: $(GOLINT) ; $(info $(M) running vet…) @ ## Run vet
	$Q $(GO) vet ./...

.PHONY: tidy
tidy: ; $(info $(M) running tidy…) @ ## Run tidy
	$Q $(GO) mod tidy

.PHONY: build-debug
build-debug: ; $(info $(M) buiding debug...)
	$Q $(GO)  build -o ./bin/$(APP) -tags debug

.PHONY: test
test: ; $(info $(M) running go test…)
	$(Q) $(GO) test ./... -tags=noexit

.PHONY: test-cover
test-cover: $(GOVERALLS) ; $(info $(M) running go test…)
	$(Q) $(GO) test -tags=noexit -race -covermode atomic -coverprofile=profile.cov ./...
	$(Q) $(GOVERALLS) -coverprofile=profile.cov -service=github

.PHONY: clean
clean: ; $(info $(M) cleaning)
	$(Q) rm -rf ./bin ./tools

## --------------------------------------
## Multi platform / arch goals
## --------------------------------------

.PHONY: gox
gox: $(GOX)
	$(Q) $(TOOLSBIN)/gox -osarch="darwin/amd64 windows/amd64 linux/amd64" -ldflags "-X $(PACKAGE)/cmd.GitCommit=$(VERSION)" -output "./bin/$(SHORT_VERSION)/{{.Dir}}_{{.OS}}_{{.Arch}}"
	$(Q) tar -czvf ./bin/$(SHORT_VERSION)/gophers_darwin_amd64.tar.gz -C ./bin/$(SHORT_VERSION)/ gophers_darwin_amd64
	$(Q) tar -czvf ./bin/$(SHORT_VERSION)/gophers_linux_amd64.tar.gz -C ./bin/$(SHORT_VERSION)/ gophers_linux_amd64
	$(Q) tar -czvf ./bin/$(SHORT_VERSION)/gophers_windows_amd64.tar.gz -C ./bin/$(SHORT_VERSION)/ gophers_windows_amd64.exe

## --------------------------------------
## Continuous Integration goal
## --------------------------------------

.PHONY: ci
ci: fmt lint vet tidy build test-cover
