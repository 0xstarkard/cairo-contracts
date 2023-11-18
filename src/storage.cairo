use starknet::ContractAddress;

#[starknet::interface]
trait ICardStorage<TContractState> {
    fn add_balance(ref self: TContractState, owner: ContractAddress, balance: u256);
    fn transfer(ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256);
    fn get_balance(self: @TContractState, owner: ContractAddress) -> u256;
}

#[starknet::contract]
mod CardStorage {
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        balance: LegacyMap<ContractAddress, u256>,
    }

    #[external(v0)]
    impl CardStorage of super::ICardStorage<ContractState> {
        fn add_balance(ref self: ContractState, owner: ContractAddress, balance: u256) {
            self.balance.write(owner, balance);
        }

        fn transfer(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            amount: u256
        ) {
            assert(amount.is_non_zero(), 'Cant be zero');
            let current_balance_sender = self.balance.read(from);
            assert(current_balance_sender.is_non_zero(), 'You dont have available funds');
            self.balance.write(from, (current_balance_sender - amount));
            let current_balance_receiver = self.balance.read(to);
            self.balance.write(to, (current_balance_receiver + amount));
        }
        
        fn get_balance(self: @ContractState, owner: ContractAddress) -> u256 {
            self.balance.read(owner)
        }
    }
}
