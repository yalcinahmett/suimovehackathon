module EventOrganizer {
  struct EventDetails {
      topic: vector<u8>,
      start_time: u64,
      end_time: u64,
      location: vector<u8>,
      max_attendees: u64,
  }

  struct Event {
      id: u64,
      title: vector<u8>,
      details: EventDetails,
      attendees: vector<address>,
      budget: u64,
      status: u8, // 0 = Created, 1 = Active, 2 = Completed, 3 = Cancelled
  }

//  resource EventPool {
//      events: vector<Event>,
//  }

  public fun init() {
      // Initialize the event pool
      EventPool { events: Vector::empty<Event>() };
  }

  public fun createEvent(title: vector<u8>, details: EventDetails, budget: u64): Event {
      // Create a new event
      let event = Event {
          id: 0, // This will be filled in by the Sui network
          title: title,
          details: details,
          attendees: Vector::empty<address>(),
          budget: budget,
          status: 0, // Event is created
      };

      // Emit an eventCreated event
      emit EventCreated { event: event };

      // Return the new event
      return event;
  }

  public fun activateEvent(eventPool: &mut EventPool, eventTitle: vector<u8>) {
      for event in &mut eventPool.events {
          if event.title == eventTitle {
              event.status = 1; // Event is active
              // Emit an eventActivated event
              emit EventActivated { event: event };
              return;
          }
      }
      abort(1, "Event not found");
  }

  public fun cancelEvent(eventPool: &mut EventPool, eventTitle: vector<u8>) {
      for event in &mut eventPool.events {
          if event.title == eventTitle {
              event.status = 3; // Event is cancelled
              // Emit an eventCancelled event
              emit EventCancelled { event: event };
              return;
          }
      }
      abort(1, "Event not found");
  }

  public fun completeEvent(eventPool: &mut EventPool, eventTitle: vector<u8>) {
      for event in &mut eventPool.events {
          if event.title == eventTitle {
              event.status = 2; // Event is completed
              // Emit an eventCompleted event
              emit EventCompleted { event: event };
              return;
          }
      }
      abort(1, "Event not found");
  }

  public fun rsvp(eventPool: &mut EventPool, eventTitle: vector<u8>, attendee: address) {
      for event in &mut eventPool.events {
          if event.title == eventTitle && event.status == 1 { // Only active events can have attendees
              Vector::push_back(&mut event.attendees, attendee);
              // Emit an rsvpAdded event
              emit RsvpAdded { event: event, attendee: attendee };
              return;
          }
      }
      abort(1, "Event not found or not active");
  }

  public fun releaseFunds(eventPool: &mut EventPool, eventTitle: vector<u8>) {
      for event in &mut eventPool.events {
          if event.title == eventTitle && event.status == 2 && Vector::length(&event.attendees) >= event.details.max_attendees { // Only completed events with maximum attendees can release funds
              // Emit an fundsReleased event
              emit FundsReleased { event: event };
              return;
          }
      }
      abort(1, "Conditions not met");
  }
}
