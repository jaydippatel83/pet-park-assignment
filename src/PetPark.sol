 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    address public owner;

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct Borrower {
        address borrower;
        bool hasBorrowed;
        uint256 age;
        Gender genderType;
        AnimalType borrowedAnimalType;
    }

    mapping(address => Borrower) public borrowers;
    mapping(AnimalType => uint256) public animalCounts;
    mapping(Gender => uint256) public genderCount;

    event Added(AnimalType indexed animalType, uint256 count);
    event Borrowed(AnimalType indexed animalType);
    event Returned(AnimalType indexed animalType);

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can perform this action"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier invalidAnimal(AnimalType animalType) {
        require(
            animalType != AnimalType.None,
            "Invalid animal"
        );
        _;
    }

    modifier invalidAnimalType(AnimalType animalType) {
        require(
            animalType != AnimalType.None,
            "Invalid animal type"
        );
        _;
    }

  
    function getAnimalTypes() public pure returns (AnimalType[] memory) {
        AnimalType[] memory animalTypes = new AnimalType[](5);
        animalTypes[0] = AnimalType.Fish;
        animalTypes[1] = AnimalType.Cat;
        animalTypes[2] = AnimalType.Dog;
        animalTypes[3] = AnimalType.Rabbit;
        animalTypes[4] = AnimalType.Parrot;
        return animalTypes;
    }

    function add(AnimalType animalType, uint256 count)
        public
        onlyOwner
        invalidAnimal(animalType)
    {
        animalCounts[animalType] += count;
        emit Added(animalType, count);
    }

    function borrow(
        uint256 age,
        Gender genderType,
        AnimalType animalType
    ) public invalidAnimalType(animalType) {
        require(age > 0, "Age must be greater than 0"); 
         if (borrowers[msg.sender].borrower == msg.sender) {
            require(borrowers[msg.sender].age == age,"Invalid Age");
            require(borrowers[msg.sender].genderType == genderType,"Invalid Gender");
        }
        require(
            !borrowers[msg.sender].hasBorrowed,
            "Already adopted a pet"
        ); 
        require(animalCounts[animalType] > 0, "Selected animal not available");
        if (genderType == Gender.Male) {
            require(
                animalType == AnimalType.Dog || animalType == AnimalType.Fish,
                "Invalid animal for men"
            );
        } else {
            if (age < 40) {
                require(
                    animalType != AnimalType.Cat,
                    "Invalid animal for women under 40"
                );
            }
        }

        borrowers[msg.sender] = Borrower(msg.sender,true, age, genderType, animalType);
        animalCounts[animalType]--;
        emit Borrowed(animalType);
    }
 

    function giveBackAnimal() public {
        require(
            borrowers[msg.sender].hasBorrowed,
            "No borrowed pets"
        );
        AnimalType animalType = borrowers[msg.sender].borrowedAnimalType;
        delete borrowers[msg.sender];
        animalCounts[animalType]++;
        emit Returned(animalType);
    }
}
