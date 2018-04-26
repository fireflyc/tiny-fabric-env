set -x

#新建channel
export CORE_PEER_MSPCONFIGPATH=/opt/crypto-config/peerOrganizations/org1.fireflyc.im/users/Admin@org1.fireflyc.im/msp
export CORE_PEER_LOCALMSPID="Org1MSP"
peer channel create -o orderer.fireflyc.im:7050 -c mychannel -f /opt/configtx/channel.tx

mv /mychannel.block /opt/configtx/

#把peer0.org1加入到channel
export CORE_PEER_MSPCONFIGPATH=/opt/crypto-config/peerOrganizations/org1.fireflyc.im/users/Admin@org1.fireflyc.im/msp
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=peer0.org1.fireflyc.im:7051
peer channel join -b /opt/configtx/mychannel.block

#把peer1.org1加入到channel
export CORE_PEER_MSPCONFIGPATH=/opt/crypto-config/peerOrganizations/org1.fireflyc.im/users/Admin@org1.fireflyc.im/msp
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=peer1.org1.fireflyc.im:7051
peer channel join -b /opt/configtx/mychannel.block

#把peer0.org2加入到channel
export CORE_PEER_MSPCONFIGPATH=/opt/crypto-config/peerOrganizations/org2.fireflyc.im/users/Admin@org2.fireflyc.im/msp
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=peer0.org2.fireflyc.im:7051
peer channel join -b /opt/configtx/mychannel.block

#把peer1.org2加入到channel
export CORE_PEER_MSPCONFIGPATH=/opt/crypto-config/peerOrganizations/org2.fireflyc.im/users/Admin@org2.fireflyc.im/msp
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=peer1.org2.fireflyc.im:7051
peer channel join -b /opt/configtx/mychannel.block

#更新org1的anchors peer
export CORE_PEER_MSPCONFIGPATH=/opt/crypto-config/peerOrganizations/org1.fireflyc.im/users/Admin@org1.fireflyc.im/msp
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=peer0.org1.fireflyc.im:7051
peer channel update -o orderer.fireflyc.im:7050 -c mychannel -f /opt/configtx/Org1MSPanchors.tx

#更新org2的anchors peer
export CORE_PEER_MSPCONFIGPATH=/opt/crypto-config/peerOrganizations/org2.fireflyc.im/users/Admin@org2.fireflyc.im/msp
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=peer0.org2.fireflyc.im:7051
peer channel update -o orderer.fireflyc.im:7050 -c mychannel -f /opt/configtx/Org2MSPanchors.tx

#安装Chaincode
#已经在docker-compose中指定了GOPATH=/opt/gopath
export CORE_PEER_MSPCONFIGPATH=/opt/crypto-config/peerOrganizations/org1.fireflyc.im/users/Admin@org1.fireflyc.im/msp
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=peer0.org1.fireflyc.im:7051
peer chaincode install -n mycc -v 1.0 -p github.com/fabcar/chaincode_example02/go/
peer chaincode instantiate -o orderer.fireflyc.im:7050 -C mychannel -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}'
peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
