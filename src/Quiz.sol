// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
   
    mapping(uint => Quiz_item) private quizzes;
    uint private quizNum = 0;

    mapping(address => uint256)[] public bets;
    uint public vault_balance;

    constructor () {
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        require(msg.sender != 0x0000000000000000000000000000000000000001, "Go away.");
        quizzes[q.id] = q;
        quizNum = q.id;
        bets.push();
    }

    function getAnswer(uint quizId) public view returns (string memory){
        Quiz_item memory q;
        q = quizzes[quizId];
        return q.answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory q;
        q = quizzes[quizId];
        q.answer = "";
        return q;
    }

    function getQuizNum() public view returns (uint){
        return quizNum;
    }
    
    function betToPlay(uint quizId) public payable {
        Quiz_item memory q;
        q = quizzes[quizId];
        require(msg.value >= q.min_bet, "bet more");
        require(msg.value <= q.max_bet, "bet less");
        bets[quizId-1][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        Quiz_item memory q;
        q = quizzes[quizId];
        if (keccak256(abi.encodePacked(ans)) == keccak256(abi.encodePacked(q.answer))){
            bets[quizId-1][msg.sender] *= 2;
            return true;
        }
        else{
            vault_balance += bets[quizId-1][msg.sender];
            bets[quizId-1][msg.sender] = 0;
            return false;
        }
    }

    function claim() public {
        uint256 sum = 0;
        for(uint256 i=0; i<quizNum; i++){
            sum += bets[i][msg.sender];
            bets[i][msg.sender] = 0;
        }
        (bool s, bytes memory r) = msg.sender.call{value: sum}("");
        require(s, "claim failed");
    }

    receive() external payable {
    }
}