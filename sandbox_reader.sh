#!/bin/bash

# Define the path to your file

FILE_PATH="/home/fedora41/books/math/Apostol_Calculus_V2.pdf"

# Define the Bubblewrap environment
bubblewrap --ro-bind /usr /usr \
    --ro-bind /lib /lib \
    --ro-bind /lib64 /lib64 \
    --ro-bind /bin /bin \
    --ro-bind /etc /etc \
    --dev-bind /dev /dev \
    --proc /proc \
    --tmpfs /tmp \
    --tmpfs /run \
    --chdir /home/user1 \
    --unshare-all \
    --hostname sandbox \
    mupdf "$FILE_PATH"
