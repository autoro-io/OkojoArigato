// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OkojoArigato {
    IERC20 public okojoCoin;

    event Arigato(
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        string comment
    );

    // okojoAddress で初期化して、ERC20トークンを結びつける
    constructor(address okojoAddress) {
        okojoCoin = IERC20(okojoAddress);
    }

    // sendArigato non-payable
    function sendArigato(
        string memory comment,
        address to,
        uint256 amount
    ) public returns (bool) {
        // ERC20 オコジョコインの残高や、送信先への送信可否を判定するためのロジック
        // 送信者が承認している送金額
        uint256 allowance = okojoCoin.allowance(msg.sender, address(this));
        // 送信者が持っている残高
        uint256 balance = okojoCoin.balanceOf(msg.sender);

        // 必須条件の確認
        // 1. 何かしらのコメントを添えること→省略
        // 2. to アドレスが有効なアドレス（nullではない）であること
        require(to != address(0), "Okojo Arigato: sendArigato to zero address");
        // 3. 送信するトークンの量 amount は、 0 以上で何かしらを送信すること
        require(amount > 0, "Okojo Arigato: Amount must be greater than 0");
        // 4. from の OkojoCoin の残高が送金額よりも大きいこと
        require(
            balance >= amount,
            "Okojo Arigato: Transfer amount exceeds OKJC balance"
        );
        // 5. from が OkojoArigato に承認しているトークンの量が、送金額よりも大きいこと
        require(
            allowance >= amount,
            "Okojo Arigato: Insufficient OKJC allowance"
        );
        // 6. from と to が実は同じではないこと
        require(msg.sender != to, "Okojo Arigato: Addresses are identical");

        // 送金実行
        okojoCoin.transferFrom(msg.sender, to, amount);

        // ありがとねイベント発火してレコードを記録
        emit Arigato(msg.sender, to, amount, comment);

        return true;
    }
}
