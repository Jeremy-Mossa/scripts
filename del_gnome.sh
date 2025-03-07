#!/bin/bash

sudo -v

rpm --erase --nodeps gnome-shell
dnf remove gnome*
