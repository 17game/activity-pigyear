pragma solidity >=0.4.22 <0.6.0;

contract Owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}

contract Goldpig is Owned {
    uint public currentId;
    mapping(uint => address) public players;
    mapping(uint => bool) public wins;
    mapping(uint => uint) public numbers;
    uint[] public level;

    constructor() public {
        currentId = 0;
        level.length = 2;
    }

    function join(uint number, address _address) public onlyOwner {
        require(uint160(players[number]) == 0);
        players[number] = _address;
        numbers[currentId] = number;
        currentId++;
        emit LogJoin(_address, number);
    }

    function lottery(string memory _btcHash) public onlyOwner {
        require(currentId > 0);
        uint count = 0;
        while(count < 31) {
            uint ran = uint(keccak256(abi.encode(_btcHash, count))) % currentId;
            draw(ran, count);
            count++;
        }
        emit LogLottery(_btcHash);
    }

    function draw(uint ran, uint count) internal {
        if(!wins[ran]) {
            if(ran == currentId) {
                draw(0, count);
            } else {
                wins[ran] = true;
                level[count * 2] = numbers[ran];
                if(count < 25) {
                    level[count * 2 + 1] = 3;
                } else if(count >= 25 && count < 30) {
                    level[count * 2 + 1] = 2;
                } else{
                    level[count * 2 + 1] = 1;
                }
                level.length += 2;
            }
        } else {
            ran++;
            draw(ran, count);
        }
    }

    event LogJoin(address indexed _address, uint indexed _index);
    event LogLottery(string indexed _btcHash);
}
