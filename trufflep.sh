#!/bin/sh

VERSION="Trufflep - v1.0.0\nAuthor: Óscar Martínez"

Help()
{
   # Display Help
   echo "Trufflep - Automatic creation of truffle and nodejs project for the development of Smart Contracts."
   echo
   echo "Syntax: trufflep [-h|-a directory]"
   echo "options:"
   echo "h     Print this Help."
   echo "a     Directory where to create the project."
   echo "v     Print script version"
   echo
}

BuildPackajeJSON()
#$1 = PROJECTNAME, $2 = DESCRIPTION, $3 = AUTHORNAME
{
  cat <<EOF > package.json
{
  "name": "$1",
  "version": "1.0.0",
  "description": "$2",
  "main": "index.js",
  "repository": "https://github.com/Deeyabo/$1.git",
  "author": "$3",
  "license": "MIT",
  "scripts": {
    "migrate": "truffle migrate --network mainnet --reset",
    "compile": "truffle compile --network mainnet",
    "migratet": "truffle migrate --network testnet --reset",
    "compilet": "truffle compile --network testnet",
    "migrated": "truffle migrate --network dev --reset",
    "compiled": "truffle compile --network dev"
  },
  "dependencies": {
    "truffle": "^5.3.2"
  },
  "devDependencies": {
    "@truffle/hdwallet-provider": "^1.2.6",
    "ethers": "^5.1.4",
    "solidity-coverage": "^0.7.16",
    "truffle-plugin-verify": "^0.5.7",
    "web3": "^1.3.5"
  }
}
EOF

}

CreateProject()
{
  
    echo "¿Nombre del proyecto?: "
    read PROJECTNAME
    echo
    echo "Descripción del proyecto: "
    read DESCRIPTION
    echo
    echo "Autor del proyecto: "
    read AUTHORNAME
    echo
    echo "¿Sobre que red van a operar los smarts contracts ( 1= Ethereum, 2 = Binance Smart Chain, 3 = Privada )?"
    read BLOCKCHAIN

    if [ "$#" -eq 1 ]
    then
        DIRECTORYNAME = "$1"
    else
        DIRECTORYNAME = "$PROJECTNAME"
    fi

    mkdir "$DIRECTORYNAME"
    cd "$DIRECTORYNAME"

    if [ "$BLOCKCHAIN" -eq 1 ]
    then
        RPC_MAINNET="https://mainnet.infura.io/v3/477b15ea8ca04d308501994e814fd3da"
        RPC_TESTNET="https://ropsten.infura.io/v3/477b15ea8ca04d308501994e814fd3da"
        echo "Indica la APIKEY de Etherscan para poder luego verificar el contrato: "
        read APIKEY
        echo
        echo "Indica la clave privada de su dirección (necesario para deploy): "
        read PRIVATEKEY
        echo

        # Escribir a ficheros apikey y clave privada
        echo $APIKEY > .apikey
        echo $PRIVATEKEY > .secret

        # Crear proyecto truffle
        echo "Creando proyecto..."
        truffle init

        echo "
const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');\n
const mnemonic = fs.readFileSync(".secret").toString().trim();
const mnemonicTestnet = fs.readFileSync(".secret").toString().trim();
const apiKey = fs.readFileSync(".apikey").toString().trim();
module.exports = {
    networks: {
        testnet: {
            provider: () => new HDWalletProvider(mnemonicTestnet, \`"$RPC_TESTNET"\`, 0, 10),
            network_id: 2,
            confirmations: 2,
            timeoutBlocks: 200,
            skipDryRun: true,
            gas: 5000000,
        },
        mainnet: {
            provider: () => new HDWalletProvider(mnemonic, \`"$RPC_MAINNET"\`),
            network_id: 1,
            confirmations: 10,
            timeoutBlocks: 200,
            skipDryRun: true,
            gas: 5000000,
        }
    },
    plugins: [
        'truffle-plugin-verify'
    ],
    api_keys: {
        etherscan: apiKey
    },
    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },
    compilers: {
      solc: {
        version: \"0.5.16\",    // Fetch exact version from solc-bin (default: truffle's version)
        settings: {          // See the solidity docs for advice about optimization and evmVersion
          optimizer: {
            enabled: true,
            runs: 999999
          },
        }
      },
    }
}
" > truffle-config.js

        #Crear esqueleto del fichero deploy
        echo "
const Token = artifacts.require(\"Token\");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(Token);
};
" > migrations/2_deploy_contracts.js


        #CREAR FICHERO PACKAGE.JSON
        BuildPackajeJSON "$PROJECTNAME" "$DESCRIPTION" "$AUTHORNAME"

        #CREAR PROYECTO NODEJS
        yarn install


    elif [ "$BLOCKCHAIN" -eq 2 ]
    then
        RPC_MAINNET="https://bsc-dataseed1.binance.org"
        RPC_TESTNET="https://data-seed-prebsc-1-s1.binance.org:8545"
        echo "Indica la APIKEY de Bscscan para poder luego verificar el contrato: "
        read APIKEY
        echo "Indica la clave privada de su dirección (necesario para deploy): "
        read PRIVATEKEY

        # Escribir a ficheros apikey y clave privada
        echo $APIKEY > .apikey
        echo $PRIVATEKEY > .secret

        # Crear proyecto truffle
        echo "Creando proyecto..."
        truffle init

        echo "
const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();
const mnemonicTestnet = fs.readFileSync(".secret").toString().trim();
const apiKey = fs.readFileSync(".apikey").toString().trim();
module.exports = {
    networks: {
        testnet: {
            provider: () => new HDWalletProvider(mnemonicTestnet, \`"$RPC_TESTNET"\`, 0, 10),
            network_id: 97,
            confirmations: 2,
            timeoutBlocks: 200,
            skipDryRun: true,
            gas: 5000000,
        },
        mainnet: {
            provider: () => new HDWalletProvider(mnemonic, \`"$RPC_MAINNET"\`),
            network_id: 56,
            confirmations: 10,
            timeoutBlocks: 200,
            skipDryRun: true,
            gas: 5000000,
        }
    },
    plugins: [
        'truffle-plugin-verify'
    ],
    api_keys: {
        bscscan: apiKey
    },
    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },
    compilers: {
      solc: {
        version: \"0.5.16\",    // Fetch exact version from solc-bin (default: truffle's version)
        settings: {          // See the solidity docs for advice about optimization and evmVersion
          optimizer: {
            enabled: true,
            runs: 999999
          },
        }
      },
    }
}
" > truffle-config.js
        #Crear esqueleto deploy

        echo "
const Token = artifacts.require(\"Token\");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(Token);
};
" > migrations/2_deploy_contracts.js

        #CREAR FICHERO PACKAGE.JSON
        BuildPackajeJSON "$PROJECTNAME" "$DESCRIPTION" "$AUTHORNAME"

        #CREAR PROYECTO NODEJS
        yarn install

    else
        HOST="localhost"
        PORT="7545"

        # Crear proyecto truffle
        echo "Creando proyecto..."
        truffle init

        echo "
module.exports = {
  networks: {
    dev: {
      host: "$HOST",     // Localhost (default: none)
      port: $PORT,         
      network_id: \"*\",       // Any network (default: none)
    },
  // Configure your compilers
  compilers: {
    solc: {
      version: \"0.5.16\",
      settings: {        
        optimizer: {
          enabled: true,
          runs: 999999
        },
      }
    },
  }
}" > truffle-config.js
        
        #Crear esqueleto deploy
        
        echo "
const Token = artifacts.require(\"Token\");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(Token);
};
" > migrations/2_deploy_contracts.js

        #CREAR FICHERO PACKAGE.JSON
        BuildPackajeJSON "$PROJECTNAME" "$DESCRIPTION" "$AUTHORNAME"

        #CREAR PROYECTO NODEJS
        yarn install
    fi

}


######################################## MAIN PROGRAM ############################################################

# Si llama a opcion de ayuda
if [ "$1" == "-h" -o "$1" == "--help" -o "$1" == "--h" -o "$1" == "-help" ]
then
    Help
    exit 1
fi

if [ "$#" -eq 1 -a "$1" == "-v" ]
then
    echo "$VERSION"
    exit 0
fi

if [ "$1" == "-a" ]
then
    if[ "$#" -gt 2 -o "$#" -eq 1 ]
    then
        echo "Trufflep: Wrong number of arguments... "
        exit 1
    else
        CreateProject "$2"
    fi
fi


#Llamar a la funcion para crear el proyecto
if [ "$#" -eq 0 ]
then
    CreateProject
fi

exit 0 