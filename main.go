/*
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.
 */

package main

import (
	goflag "flag"
	"os"

	flag "github.com/spf13/pflag"
	"k8s.io/klog/v2"

	"github.com/the-gophers/gophers/cmd"
)

func main() {
	flagSet := goflag.NewFlagSet(os.Args[0], goflag.ExitOnError)
	klog.InitFlags(flagSet)
	_ = flagSet.Parse(os.Args[1:]) //nolint: error will never be returned due to ExitOnError
	flag.CommandLine.AddGoFlagSet(flagSet)
	cmd.Execute()
}
