#!/bin/sh -e

GENESIS="/root/genesis.json"
HOME="/root/node"
BINARY="/binary"

if [ -z "$MONIKER" ]; then
    echo "error: MONIKER should be specified in evironment." >&2
    exit 1
fi

if [ ! -f "$GENESIS" ]; then
    echo "error: $GENESIS was not found, mount it as a docker volume" >&2
    exit 1
fi

if [ ! -f "$BINARY" ]; then
    echo "error: binary was expected at path $BINARY, but wasn't found. mount it as a docker volume" >&2
    exit 1
fi

if [ -z "$PEER"]; then
    echo "error: PEER should be specified in environment. format: id@ip:port"
fi

mkdir -p "$HOME/config"
cp "$GENESIS" "$HOME/config/genesis.json"

chmod +x $BINARY
$BINARY validate-genesis

echo "Starting fishermen"

$BINARY start \
    --home "$HOME" \
    --moniker $MONIKER \
    --address tcp://0.0.0.0:26658 \
    --p2p.laddr tcp://0.0.0.0:26656 \
    --rpc.laddr tcp://0.0.0.0:26657 \
    --p2p.persistent_peers $PEER
