# -*- mode: nix; indent-tabs-mode: nil; tab-width: 2 -*-
{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./derivation.nix {}
