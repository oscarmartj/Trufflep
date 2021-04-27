# Trufflep
How to install?

1. Make sure that the trufflep.sh script has execution permissions, if not, use the following command: chmod +x trufflep.sh
2. Rename the script file from "trufflep.sh" to "trufflep", thus removing the file extension.
3. Copy the script file and paste it into the "/bin" directory of your operating system.
4. Ready! Now you can use the script to create truffle & node projects automatically, using the "trufflep" command.

# Trufflep script options
Available options?

- To see the version of the script: trufflep -v
- To open the help menu: trufflep -h
- To create a project in a specific directory: trupplep -a [directory]
- To create a project in the current directory: trufflep

# Relax!

During the creation of a project you must indicate the Etherscan APIKEY (or bscscan) to later verify the contracts and also you must indicate the private key of your wallet to be able to deploy the contracts. In both cases, this private information is only stored on your computer locally in the .secret and .apikey files. At no time is it sent to any third party service!
