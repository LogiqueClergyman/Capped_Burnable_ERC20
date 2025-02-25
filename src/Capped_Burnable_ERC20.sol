// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Capped_Burnable_ERC20 {
    string private _name;
    string private _symbol;
    uint256 private _cap;
    uint8 private _decimals;
    uint256 private _totalSupply;

    event _approve_(address indexed owner, address indexed spender, uint256 value);
    event _transfer_(address indexed from, address indexed to, uint256 value);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(string memory name_, string memory symbol_, uint256 cap_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _cap = cap_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function cap() public view returns (uint256) {
        return _cap;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(_balances[msg.sender] >= value, "Balance insufficient");
        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit _transfer_(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "invalid address");
        _allowances[msg.sender][spender] = value;
        emit _approve_(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(from != address(0), "invalid sender");
        require(to != address(0), "invalid recipient");
        require(_allowances[from][msg.sender] >= value, "insufficient allowance");
        require(_balances[from] >= value, "insufficent balance");
        _allowances[from][msg.sender] -= value;
        _balances[from] -= value;
        _balances[to] += value;
        emit _transfer_(from, to, value);
        return true;
    }

    function mint(address to, uint256 value) public returns (bool) {
        require(to != address(0), "invalid recipient");
        require(_totalSupply + value <= _cap, "cap exceeded");
        _balances[to] += value;
        _totalSupply += value;
        return true;
    }

    function burn(uint256 value) public returns (bool) {
        require(_balances[msg.sender] >= value, "insufficient value");
        _balances[msg.sender] -= value;
        _totalSupply -= value;
        return true;
    }
}
