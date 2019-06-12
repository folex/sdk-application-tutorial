#!/bin/sh -e

function seed_init {
    nsd init $MONIKER --chain-id namechain 
    echo hackhack | nscli keys add first-key
    nsd add-genesis-account $(nscli keys show first-key -a) 1000nametoken,100000000stake
    nscli config chain-id namechain 
    nscli config output json 
    nscli config indent true 
    nscli config trust-node true 
    echo hackhack | nsd gentx --name first-key 
    nsd collect-gentxs

    echo "Starting seed node"

    nsd start --moniker $MONIKER\
         --address tcp://0.0.0.0:26658 \
         --p2p.laddr tcp://0.0.0.0:26656 \
         --rpc.laddr tcp://0.0.0.0:26657
}

function peer_init {
    if [ ! -f "$GENESIS" ]; then 
        echo "error: $GENESIS was not found, required in 'peer' mode" >&2
        exit 1
    fi

    if [ -z "$PEER"]; then
        echo "error: specify peer as a 3rd argument. format: id@ip:port"
    fi

    mkdir -p /root/.nsd/config
    cp "$GENESIS" /root/.nsd/config/genesis.json
    nsd validate-genesis

    echo "Starting peer node"

    nsd start --moniker $MONIKER\
        --address tcp://0.0.0.0:26658 \
        --p2p.laddr tcp://0.0.0.0:26656 \
        --rpc.laddr tcp://0.0.0.0:26657 \
        --p2p.persistent_peers $PEER
}

MODE=$1
MONIKER=$2
PEER=$3
GENESIS="/root/genesis.json"

if [ -z "$MODE" ]; then
    echo "error: mode should be specified as a first argument. Possible values: seed, peer" >&2
    exit 1
fi

if [ -z "$MONIKER" ]; then
    echo "error: moniker should be specified as a second argument." >&2
    exit 1
fi

case "$MODE" in
    seed)
        seed_init
        ;;

    peer)
        peer_init
        ;;
    
    *)
        echo "error: mode should be specified as a first argument. Possible values: seed, peer" >&2
        exit 1
    ;;
esac
