/*
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.
 */

package cmd

import (
	"context"
	"fmt"

	"github.com/spf13/cobra"

	"github.com/the-gophers/gophers/xcobra"
)

type (
	additionArgs struct {
		left, right int
	}
)

// NewAddCmd will add left and right together and print the outcome
func NewAddCmd() (*cobra.Command, error) {
	var oArgs additionArgs
	cmd := &cobra.Command{
		Use:   "add",
		Short: "add two ints",
		Run: xcobra.RunWithCtx(func(ctx context.Context, cmd *cobra.Command, args []string) error {
			_, err := fmt.Printf("%d + %d = %d\n", oArgs.left, oArgs.right, oArgs.left+oArgs.right)
			return err
		}),
	}

	flags := cmd.Flags()
	flags.IntVarP(&oArgs.left, "left", "l", 0, "left argument")
	if err := cmd.MarkFlagRequired("left"); err != nil {
		return cmd, err
	}

	flags.IntVarP(&oArgs.right, "right", "r", 0, "right argument")
	if err := cmd.MarkFlagRequired("right"); err != nil {
		return cmd, err
	}

	return cmd, nil
}
