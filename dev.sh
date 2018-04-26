export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}

CHANNEL_NAME="mychannel"
PROJECT_NAME=dev
IMAGE_TAG=x86_64-1.1.0
DOMAIN="fireflyc.im"

function printHelp () {
  echo "Usage: "
  echo "  dev.sh gen|up|down|clean"
  echo "  dev.sh -h|--help (print this message)"
  echo "    <mode> - one of 'up', 'down' or 'gen'"
  echo "      - 'gen' - generate required certificates and genesis block"
  echo "      - 'up' - bring up the network with docker-compose up"
  echo "      - 'down' - clear the network with docker-compose down"
  echo "      - 'clean' - delete 'var' 'crypto-config' 'configtx'"
  echo
}

function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi
  if [ ! -d "configtx" ]; then
    mkdir configtx
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  set -x
  configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./configtx/genesis.block
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo
  echo "#################################################################"
  echo "### Generating channel configuration transaction 'channel.tx' ###"
  echo "#################################################################"
  set -x
  configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./configtx/channel.tx -channelID $CHANNEL_NAME
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org1MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./configtx/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org2MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./configtx/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org2MSP..."
    exit 1
  fi
  echo
}

function generateCerts (){
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"

  if [ -d "crypto-config" ]; then
    rm -Rf crypto-config
  fi
  set -x
  cryptogen generate --config=./crypto-config.yaml
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo
}

MODE=$1;shift

if [ "$MODE" == "gen" ]; then
  generateCerts
  generateChannelArtifacts
elif [[ "$MODE" == "up" ]]; then
  PROJECT_NAME=$PROJECT_NAME DOMAIN=$DOMAIN IMAGE_TAG=$IMAGE_TAG docker-compose -p $PROJECT_NAME up -d
elif [ "$MODE" == "down" ]; then
  #rm -rf data
  PROJECT_NAME=$PROJECT_NAME DOMAIN=$DOMAIN IMAGE_TAG=$IMAGE_TAG docker-compose -p $PROJECT_NAME down
elif [ "$MODE" == "clean" ]; then
  rm -rf configtx
  rm -rf crypto-config
  rm -rf var
else
  printHelp
  exit 1
fi