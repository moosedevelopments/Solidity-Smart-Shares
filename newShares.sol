pragma solidity ^0.4.18;

interface tokenRecipient { function recieveApproval(address _from,
uint256 _value, uint256 _price, address _token, bytes _extraData) public; }


contract MasterShareContract {

    // This is the Constructor Function;

    function MasterShareContract(address _signatureControler,
        uint256 initialShareCap) public {
        _signatureControler = msg.sender;
        signatureControler = _signatureControler;
        MarketCap += initialShareCap * 10 **uint256(decimals);
            initialShareCap = 100000;
            balanceOf[msg.sender] = initialShareCap;
            CompanyName = "Moose Blockchain Development Inc";
            StockSymbol = "MOOSE";
            LastPrice = 0;
            OfferingClass = "Crowd Source";
    }

// All variables go in this section;

    address private signatureControler;
    string public CompanyName;
    string public StockSymbol;
    string public OfferingClass;
    uint256 private LastPrice;
    uint8 private decimals = 2;
    uint256 public MarketCap = 100000;

// All Struct's go in this section;

    struct RegisteredAddresses {
        string clientName;
        uint256 clientID;
        address walletAddr;
        string emailaddr;
        uint256 accType;
        bool status;
        string mailServiceAddress;
    }

    struct RegisteredAdmins {
        string employeeName;
        address accountWallet;
        bool status;
    }

    struct AccTransferLimitsBase {
        uint256 baseLimit;
        // This function will need to be sent to a master control contract speerate from the vendor issueing contract
    }

// Modifier's go in this section; This Secection sets the security profiles;

    event ErrorLog(address user, string returnError);
    string returnAdminError = "This action is not authorized and has been logged";
    string errorMessageAccLim = "This purchase exceeds your current investing limit";
    string userStatusError = "Your wallet is not registered or has been disabled";
    string errorAdminNA = "You are not an active and/or authorized Administrator";
    string notSame = "You cannot send shares to your own account";

        function runActiveUser() private {
            if(msg.sender==registeredAddresses[msg.sender].walletAddr &&
                registeredAddresses[msg.sender].status ==true){
                return;
            } else {
              ErrorLog(msg.sender, userStatusError);
              revert();
            }
        }

        function runActiveUserAdmin(address _to, address _from) private {
            if( _to==registeredAddresses[_to].walletAddr &&
                registeredAddresses[_to].status ==true &&
                _from==registeredAddresses[_from].walletAddr &&
                registeredAddresses[_from].status ==true
                ){
                return;
            } else {
              ErrorLog(msg.sender, userStatusError);
              revert();
            }
        }

        function onlysignatureControler() private {
            if(msg.sender==signatureControler){
            return;
            } else{
              ErrorLog(msg.sender, returnAdminError);
              revert();
            }
        }


        function verifyAccountLimits(address _to, uint256 _price) private {
            if(accTransferLimitsBase[_to].baseLimit + _price <= 2500){
            return;
            } else{
              ErrorLog(msg.sender, errorMessageAccLim);
              revert();
            }
        }

        function runAdminCheck() private {
            if(msg.sender==registeredAdmins[msg.sender].accountWallet &&
                registeredAdmins[msg.sender].status ==true){
            return;
          } else {
            ErrorLog(msg.sender, errorAdminNA);
            revert();
          }
        }

        function notSameAddr(address _to) private {
            if(msg.sender==_to) {
                revert();
            } else {
                ErrorLog(msg.sender, notSame);
                return;
            }
        }


// Mapping Code goes in this section;

    mapping(address => RegisteredAddresses) private registeredAddresses;
    address[] public walletList;

    mapping(address => RegisteredAdmins) private registeredAdmins;
    address[] public adminList;

    mapping(address => AccTransferLimitsBase) private accTransferLimitsBase;
    address[] public accLimits;  //to be set in Canadian Dollars.
    // These limits apply to how much a user can buy, they do NOT apply to
    // how much a user can sell.

// Function's go in this section;


    // Client Functions

    function getClientName() public constant returns (string) {
        return registeredAddresses[msg.sender].clientName;
    }

    function getShareBalance() public constant returns (uint256) {
        return balanceOf[msg.sender];
    }

    function getClientId() public constant returns (uint256) {
        return registeredAddresses[msg.sender].clientID;
    }

    function getClientEmail() public constant returns (string) {
        return registeredAddresses[msg.sender].emailaddr;
    }

    function getClientStatus() public constant returns (bool) {
        return registeredAddresses[msg.sender].status;
    }

    function getClientWallet() public constant returns (address) {
        return registeredAddresses[msg.sender].walletAddr;
    }

    function getHoldingsAtLastPrice() public constant returns (uint256) {
        uint256 _profileValue = balanceOf[msg.sender] * LastPrice;
        return _profileValue;
    }

    function getClientMailServiceAddress() public constant returns (string) {
        return registeredAddresses[msg.sender].mailServiceAddress;
    }

    // Administrative Functions


    function countRegisteredAddresses() public constant returns(uint256 TotalIs)
        {   return walletList.length;
    }

    function callAccountStatus(address _walletAddr) public constant
        returns(bool status) {
        return registeredAddresses[_walletAddr].status;
    }

    function addRegisteredAddress (
            string _clientName,
            uint256 _clientID,
            address _walletAddr,
            string _emailaddr,
            uint256 _accType,
            bool _status,
            string _mailServiceAddress
                                    )
    public returns (uint rowNumber) {
       runAdminCheck();
       require(!registeredAddresses[_walletAddr].status ==true);
       registeredAddresses[_walletAddr].clientName = _clientName;
       registeredAddresses[_walletAddr].clientID = _clientID;
       registeredAddresses[_walletAddr].walletAddr = _walletAddr;
       registeredAddresses[_walletAddr].emailaddr = _emailaddr;
       registeredAddresses[_walletAddr].accType = _accType;
       registeredAddresses[_walletAddr].status = _status;
       registeredAddresses[_walletAddr].mailServiceAddress = _mailServiceAddress;
       return walletList.push(_walletAddr) - 1;
    }

    function setAddressStatus (address _walletAddr, bool _active) public
        returns (bool) {
        runAdminCheck();
        registeredAddresses[_walletAddr].status = _active;
        return registeredAddresses[_walletAddr].status;
    }

    function changeAddressName(address _walletAddr, string _Name) public
        returns (string) {
       runAdminCheck();
       registeredAddresses[_walletAddr].clientName = _Name;
       return registeredAddresses[_walletAddr].clientName;
    }

    // This Section is the start of Security Validation of Administrators

    function addRegisteredAdmins (
        string _employeeName,
        address _accountWallet,
        bool _status
        )
    public returns (uint rowNumber) {
        onlysignatureControler();
        require(!registeredAdmins[_accountWallet].status ==true);
        registeredAdmins[_accountWallet].employeeName = _employeeName;
        registeredAdmins[_accountWallet].accountWallet = _accountWallet;
        registeredAdmins[_accountWallet].status = _status;
        return adminList.push(_accountWallet) -1;
    }



    // This is the start of the Share Issueing Code;

    mapping (address => uint256) private balanceOf;
    mapping (address => mapping (address => uint256)) private allowance;


    event TransferPrice(address indexed from, address indexed to, uint256 price);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function _transfer(address _from, address _to, uint _value, uint256 _price)
      internal  {
            require(_to !=0x0);
            require(_price !=0);
            require(balanceOf[_from] >= _value);
            require(balanceOf[_to] + _value > balanceOf[_to]);
            uint previousBalances = balanceOf[_from] + balanceOf[_to];
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;
            Transfer(_from, _to, _value);
            accTransferLimitsBase[_to].baseLimit += _price;
            TransferPrice(_from, _to, _price);
            LastPrice = _price;
            assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        }

        function transfer(address _to, uint256 _value, uint256 _price) public {
            runAdminCheck();
            require(_to==registeredAddresses[_to].walletAddr);
            require(registeredAddresses[_to].status==true );
            notSameAddr(_to);
            _transfer(msg.sender, _to, _value, _price);
        }

        function approve(address _spender, uint256 _value) private returns (bool) {
            allowance[msg.sender][_spender] = _value;
            return true;
        }

    function approveAndCall(address _spender, uint256 _value, uint256 _price,
        bytes _extraData) private returns (bool success) {
            tokenRecipient spender = tokenRecipient(_spender);
            if (approve(_spender, _value)) {
                spender.recieveApproval(msg.sender, _value, _price, this, _extraData);
                return true;
            }
        }


// This is an administrative override function only.
// Not to be used with out legal authority of a court or tribunel

    event OverrideTransfer(address from, address to, string memo);

    function overrideTransfer(address _from, address _to, uint256 _value,
        uint256 _price, string _memo) public
        returns (bool success) {
        runAdminCheck();
        OverrideTransfer(_from, _to, _memo);
        _transfer(_from, _to, _value, _price);
        return true;
    }

}
