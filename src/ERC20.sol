// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ERC20Token {

    // DESCRIBING METADATA OF THE ERC-20 TOKEN
// Name :- Krot-Token [10]
    bytes32 private constant nameOfTokenInBytes = 0x4b726f742d546f6b656e00000000000000000000000000000000000000000000 ;
// Symbol :- KT
    bytes32 private constant tokenSymbolInBytes = 0x4b54000000000000000000000000000000000000000000000000000000000000 ;
// Decimal of the token
    uint256 private tokenDecimal = 18;

    uint256 public totalSupply;
// Mapping for the balance check of the addresses
    mapping(address => uint256) public balanceOf;
// Mapping for  approvals of spender and approvals
    mapping(address => mapping(address => uint256)) public allowance;

// Function to get the name of the token
    function getName() external pure returns (string memory _tokenName) {
        assembly {
// @note :: Load the free memory pointer into variable 
//          0x40 is the standard location where the free memory pointer is kept
            _tokenName := mload(0x40)
// @note :: Set the length of string which is going to be the name
//          The fist word of memory in a string holds the length of the string, Here it is 10
            mstore(_tokenName,10)
// @note ::  Store the tokenNameInBytes at _tokenName + 20 
//           Adding 0x20 to the tokenName to skip the length and write the actual string data which is the name of the token in bytes
            mstore(add(_tokenName, 0x20), nameOfTokenInBytes)
// @note :: Update the free memory pointer to _tokenName + 0x40
            mstore(0x40, add(_tokenName, 0x40))
        }   
    }


    function getSymbol() external pure returns (string memory) {
        assembly {
// @note :: Load the free memory pointer in ptr variable
            let ptr := mload(0x40)
// @note :: Write the offset for the string 
//          This will tells the EVM where the actual string is starting
            mstore(ptr, 0x20)
// @note :: Store the string length 
//          Here we specifies the string length as 2 [Symbol string length] 
            mstore(add(ptr,0x20), 2)
// @note :: Write the actual symbol detail at ptr + 0x40
            mstore(add(ptr,0x40), tokenSymbolInBytes)
// @note :: Return the memory from ptr with size 0x60
            return(ptr,0x60)
        }
    }

    function getDecimal() public view returns(uint256) {
        assembly {
// @note :: Load the free memory pointer 
            let ptr := mload(0x40)
// @note :: Stores the token decimal value into memory
//          Directly accesing the value of tokenDecimal from the storage slot where it is stored
//          Storing that value into the memory at ptr
            mstore(ptr, sload(tokenDecimal.slot))
// @note :: Return the decimal value of 32 bytes from memory
            return(ptr, 0x20)
        }
    }

    function mint(address to, uint256 amount) external {
        assembly {
// @note :: Getting the total Supply from the storage directly using slot
            let totalSupplySlot := totalSupply.slot
// @note :: Loading the current total supply
            let totalSupplyBefore := sload(totalSupplySlot)
// @note :: Describing the max uint 256 value where the value is 2^256 - 1
            let max_uint := sub(exp(2,256),1)

// @note :: subtracting the totalSupplyBefore from maxUint
//          If the amount is greater than the subtracted result amount then it will result in 1 otherwise it will return 0 
//          So if the result is 0 means the amount is less than the subtracted result it will again check the result for 0 
//          It will return the 0 again and it will revert with 0,0
            if iszero(iszero(gt(amount, sub(max_uint, totalSupplyBefore)))) {
// @note :: Preventing overflow if it overflows it will revert
                revert(0,0)
            }

// @note If the condition passes and the function didn't revert then
// @note ::  Increasing the value of the totalSupply by adding the mint amount
            let totalSupplyAfter := add(totalSupplyBefore,amount)
// @note :: Storing the value in the storage [The updated totalSupply value]
            sstore(totalSupplySlot, totalSupplyAfter)
// @note :: Getting the free memory pointer
            let ptr := mload(0x40)
// @note :: Writing the sender address in the memory
// @->      mstore(ptr, caller())  //@follow-up [If we use the caller() it will use the msg.sender address and not the address passed in the parameter]
            mstore(ptr, to)
// @note :: Accesing the balanceOf slot directly using slot
            let balanceOfSlot := balanceOf.slot
// @note :: Preparing the balanceOf mapping slot
            mstore(add(ptr, 0x20), balanceOfSlot)
// @note :: hashing the slot to get the mapping slot storage location
            let slot := keccak256(ptr, 0x40)
// @note :: Updating the sender balance by the amount they mint
            let balanceAfter := add(sload(slot), amount)
// @note :: Storing the value in the storage slot
            sstore(slot, balanceAfter)
        }
    }

    function getTotalSupply() public view returns(uint256) {
        assembly {
// @note :: Getting a free memory pointer
            let ptr := mload(0x40)
// @note :: Accessing the totalSupply from the storage using the slot directly
            mstore(ptr, sload(totalSupply.slot))
// @note :: Returning the value
            return(ptr,0x20)
        }
    }

    function balanceOfUser(address account) public view returns (uint256) {
        assembly {
// @note :: Getting the free memory pointer
            let ptr := mload(0x40)
// @note :: Storing the address of the account in the memory
            mstore(ptr, account)
// @note :: Accessing the balanceOf directly from the storage using slot
            mstore(add(ptr,0x20), balanceOf.slot)
// @note :: Hashing the slot so that we can get the storage location
            let slot := keccak256(ptr, 0x40)
// @note :: Loading the value from the slot which is found using the hash storage location
            mstore(ptr, sload(slot))
// @note :: Returning the balance of the address 
            return(ptr, 0x20)
        }
    }
}