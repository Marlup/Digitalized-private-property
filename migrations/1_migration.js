const Contract = artifacts.require("Contract");

module.exports = function (deployer, network, accounts) {
    const party1 = accounts[1];
    const party2 = accounts[2];
    const title = web3.utils.toHex("Contract Title");
    const points = web3.utils.toHex("Contract Points");
    deployer.deploy(Contract, 1, title, points, [party1, party2]);
};