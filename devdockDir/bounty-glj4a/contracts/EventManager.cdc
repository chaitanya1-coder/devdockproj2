access(all) contract EventManager {
    access(all) var events: {UInt64: Event}
    access(all) var nextEventId: UInt64

    access(all) struct Event {
        access(all) let id: UInt64
        access(all) let name: String
        access(all) let date: UFix64
        access(all) let maxTickets: UInt64
        access(all) var soldTickets: UInt64
        access(all) var isActive: Bool

        init(id: UInt64, name: String, date: UFix64, maxTickets: UInt64) {
            self.id = id
            self.name = name
            self.date = date
            self.maxTickets = maxTickets
            self.soldTickets = 0
            self.isActive = true
        }
    }

    access(all) resource EventAdmin {
        access(all) fun createEvent(name: String, date: UFix64, maxTickets: UInt64) {
            let event = Event(
                id: EventManager.nextEventId,
                name: name,
                date: date,
                maxTickets: maxTickets
            )
            EventManager.events[EventManager.nextEventId] = event
            EventManager.nextEventId = EventManager.nextEventId + 1
        }

        access(all) fun endEvent(eventId: UInt64) {
            EventManager.events[eventId]?.isActive = false
        }
    }

    init() {
        self.events = {}
        self.nextEventId = 1

        let admin <- create EventAdmin()
        self.account.save(<-admin, to: /storage/EventAdmin)
    }
}