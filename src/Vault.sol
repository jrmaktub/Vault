// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//  import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC4626.sol";

//import for Remiix
import "https://github.com/jspruance/erc4626-vault-tutorial/blob/main/contracts/ERC4626Fees.sol";

contract Vault is ERC4626Fees  {
    address payable public vaultOwner;
    uint256 public entryFeeBasisPoints;

    constructor(IERC20 _asset, uint256 _basisPoints) ERC4626(_asset) ERC20("Vault Ocean Token", "vOCT"){
       
        vaultOwner = payable(msg.sender);
        entryFeeBasisPoints = _basisPoints;

    }

        /** @dev See {IERC4626-deposit}. */
    function deposit(uint256 assets, address receiver) public virtual override returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);
        afterDeposit(assets);

        return shares;
    }

    /** @dev See {IERC4626-mint}.
     *
     * As opposed to {deposit}, minting is allowed even if the vault is in a state where the price of a share is zero.
     * In this case, the shares will be minted without requiring any assets to be deposited.
     */
    function mint(uint256 shares, address receiver) public virtual override  returns (uint256) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);
        afterDeposit(assets);

        return assets;
    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(uint256 assets, address receiver, address owner) public virtual override returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        beforeWithdraw(assets,shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-redeem}. */
    function redeem(uint256 shares, address receiver, address owner) public virtual override  returns (uint256) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

        // === Fee configuration ===

    function _entryFeeBasisPoints() internal view override  returns (uint256) {
        return entryFeeBasisPoints; // replace with e.g. 100 for 1%
    }

    function _entryFeeRecipient() internal view override  returns (address) {
        return vaultOwner; // replace with e.g. a treasury address
    }

        /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function afterDeposit(uint256 assets) internal virtual {
        uint256 interest = assets/ 10;
        SafeERC20.safeTransferFrom(IERC20(asset()), vaultOwner, address(this),interest);
 
    }
    
    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {

    }


  
}