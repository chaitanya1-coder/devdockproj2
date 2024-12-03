import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

access(all) contract EventTicket: NonFungibleToken {
    access(all) var totalSupply: UInt64
    access(all) let CollectionStoragePath: StoragePath
    access(all) let CollectionPublicPath: PublicPath
    access(all) let MinterStoragePath: StoragePath

    access(all) event ContractInitialized()
    access(all) event Withdraw(id: UInt64, from: Address?)
    access(all) event Deposit(id: UInt64, to: Address?)
    access(all) event Minted(id: UInt64, recipient: Address)
    access(all) event Burned(id: UInt64)

    access(all) resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        access(all) let id: UInt64
        access(all) let eventId: UInt64String: String}
        
        init(id: UInt64, eventId: U {
            self.id = id
            self.eventId = eventId
            self.metadata = metadata
        }
    }

    access(all) resource interface EventTicketCollectionPublic {
        access(all) fun deposit(token: @NonFungibleToken.NFT)
        access(all) fun getIDs(): [UInt64]
        access(all) fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    }

    access(all) resource Collection: EventTicketCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        access(all) var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        access(all) fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("NFT not found")
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }

        access(all) fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @EventTicket.NFT
            let id: UInt64 = token.id
            self.ownedNFTs[id] <-! token
            emit Deposit(id: id, to: self.owner?.address)
        }

        access(all) fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        access(all) fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    access(all) resource NFTMinter {
        access(all) fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, eventId: UInt64
            let token <- create NFT(
                id: EventTicket.totalSupply,
                event
            )
            EventTicket.totalSupply = EventTicket.totalSupply + 1
            emit Minted(id: token.id, recipient: recipient.owner!.address)
            recipient.deposit(token: <-token)
        }
    }

    init() {
        self.totalSupply = 0
        self.CollectionStoragePath = /storage/EventTicketCollection
        self.CollectionPublicPath = /public/EventTicketCollection
        self.MinterStoragePath = /storage/EventTicketMinter

        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
    }
}