const Contract = artifacts.require("Contract");

module.exports = function (deployer, network, accounts) {
    const party1 = accounts[1];
    const party2 = accounts[2];
    const title = web3.utils.toHex("Contract Title");
    const detail = web3.utils.toHex("Contract Detail");
    const shares = 8;
    deployer.deploy(Contract, 1, title, detail, shares, [party1, party2]);
};