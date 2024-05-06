#[allow(unused_const)]
module decentralized_learning_system ::decentralized_learning_system {
    // Imports
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use std::option::{Option, none, some, is_some, contains, borrow};

    // Errors
    const EInvalidBooking: u64 = 1;
    const EInvalidSession: u64 = 2;
    const EDispute: u64 = 3;
    const EAlreadyResolved: u64 = 4;
    const ENotBooked: u64 = 5;
    const EInvalidWithdrawal: u64 = 7;
    const EAssignmentDeadlinePassed: u64 = 8;

    // Struct definitions
    struct LearningSession has key, store {
        id: UID,
        student: address,
        teacher: Option<address>,
        description: vector<u8>, // Brief description of the session
        learning_objectives: vector<u8>, // Goals or objectives of the learning session
        materials: vector<vector<u8>>, // Learning materials (documents, links, videos, etc.)
        price: u64,
        escrow: Balance<SUI>,
        sessionScheduled: bool,
        dispute: bool,
        progress: u8, // Progress of the session (0-100%)
        feedback: Option<vector<u8>>, // Feedback provided by the student
        rating: Option<u8>, // Rating provided by the student
        sessionDeadline: Option<u64>, // Deadline for the learning session
        assignmentDeadline: Option<u64>, // Deadline for assignments related to the session
    }

    // Public - Entry functions

    // Function to book a learning session
    public entry fun book_learning_session(description: vector<u8>, learning_objectives: vector<u8>, materials: vector<vector<u8>>, price: u64, ctx: &mut TxContext) {
        let session_id = object::new(ctx);
        transfer::share_object(LearningSession {
            id: session_id,
            student: tx_context::sender(ctx),
            teacher: none(), // Set to an initial value, can be updated later
            description: description,
            learning_objectives: learning_objectives,
            materials: materials,
            price: price,
            escrow: balance::zero(),
            sessionScheduled: false,
            dispute: false,
            progress: 0,
            feedback: none(),
            rating: none(),
            sessionDeadline: none(), // Initialize to none
            assignmentDeadline: none(), // Initialize to none
        });
    }

    // Function to request a learning session
    public entry fun request_learning_session(learning_session: &mut LearningSession, ctx: &mut TxContext) {
        assert!(!is_some(&learning_session.teacher), EInvalidBooking);
        learning_session.teacher = some(tx_context::sender(ctx));
    }

    // Function to submit a learning session
    public entry fun submit_learning_session(learning_session: &mut LearningSession, ctx: &mut TxContext) {
        assert!(contains(&learning_session.teacher, &tx_context::sender(ctx)), EInvalidSession);
        learning_session.sessionScheduled = true;
    }

    // Function to dispute a learning session
    public entry fun dispute_learning_session(learning_session: &mut LearningSession, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx), EDispute);
        learning_session.dispute = true;
    }

    // Function to resolve a learning session dispute
    public entry fun resolve_learning_session(learning_session: &mut LearningSession, resolved: bool, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx), EDispute);
        assert!(learning_session.dispute, EAlreadyResolved);
        assert!(is_some(&learning_session.teacher), EInvalidBooking);
        let escrow_amount = balance::value(&learning_session.escrow);
        let escrow_coin = coin::take(&mut learning_session.escrow, escrow_amount, ctx);
        if (resolved) {
            let teacher = *borrow(&learning_session.teacher);
            // Transfer funds to the teacher
            transfer::public_transfer(escrow_coin, teacher);
        } else {
            // Refund funds to the student
            transfer::public_transfer(escrow_coin, learning_session.student);
        };

        // Reset session state
        learning_session.teacher = none();
        learning_session.sessionScheduled = false;
        learning_session.dispute = false;
    }

    // Function to release payment for a learning session
    public entry fun release_payment(learning_session: &mut LearningSession, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx), ENotBooked);
        assert!(learning_session.sessionScheduled && !learning_session.dispute, EInvalidSession);
        assert!(is_some(&learning_session.teacher), EInvalidBooking);
        let teacher = *borrow(&learning_session.teacher);
        let escrow_amount = balance::value(&learning_session.escrow);
        let escrow_coin = coin::take(&mut learning_session.escrow, escrow_amount, ctx);
        // Transfer funds to the teacher
        transfer::public_transfer(escrow_coin, teacher);

        // Reset session state
        learning_session.teacher = none();
        learning_session.sessionScheduled = false;
        learning_session.dispute = false;
    }

    // Function to add funds to a learning session
    public entry fun add_funds_to_session(learning_session: &mut LearningSession, amount: Coin<SUI>, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == learning_session.student, ENotBooked);
        let added_balance = coin::into_balance(amount);
        balance::join(&mut learning_session.escrow, added_balance);
    }

    // Function to request a refund for a learning session
    public entry fun request_refund(learning_session: &mut LearningSession, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == learning_session.student, ENotBooked);
        assert!(learning_session.sessionScheduled == false, EInvalidWithdrawal);
        let escrow_amount = balance::value(&learning_session.escrow);
        let escrow_coin = coin::take(&mut learning_session.escrow, escrow_amount, ctx);
        // Refund funds to the student
        transfer::public_transfer(escrow_coin, learning_session.student);

        // Reset session state
        learning_session.teacher = none();
        learning_session.sessionScheduled = false;
        learning_session.dispute = false;
    }

    // Function to mark a session as complete
    public entry fun mark_session_complete(learning_session: &mut LearningSession, ctx: &mut TxContext) {
        assert!(contains(&learning_session.teacher, &tx_context::sender(ctx)), ENotBooked);
        learning_session.sessionScheduled = true;
        // Additional logic to mark the session as complete
    }

    // Function to cancel a learning session
    public entry fun cancel_learning_session(learning_session: &mut LearningSession, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx) || contains(&learning_session.teacher, &tx_context::sender(ctx)), ENotBooked);

        // Refund funds to the student if not yet paid
        if (is_some(&learning_session.teacher) && !learning_session.sessionScheduled && !learning_session.dispute) {
            let escrow_amount = balance::value(&learning_session.escrow);
            let escrow_coin = coin::take(&mut learning_session.escrow, escrow_amount, ctx);
            transfer::public_transfer(escrow_coin, learning_session.student);
        };

        // Reset session state
        learning_session.teacher = none();
        learning_session.sessionScheduled = false;
        learning_session.dispute = false;
    }

    // Function to update session description
    public entry fun update_session_description(learning_session: &mut LearningSession, new_description: vector<u8>, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx), ENotBooked);
        learning_session.description = new_description;
    }

    // Function to update session price
    public entry fun update_session_price(learning_session: &mut LearningSession, new_price: u64, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx), ENotBooked);
        learning_session.price = new_price;
    }

    // Function to provide feedback
    public entry fun provide_feedback(learning_session: &mut LearningSession, feedback: vector<u8>, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx) && learning_session.sessionScheduled, ENotBooked);
        learning_session.feedback = some(feedback);
    }

    // Function to provide rating
    public entry fun provide_rating(learning_session: &mut LearningSession, rating: u8, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx) && learning_session.sessionScheduled, ENotBooked);
        learning_session.rating = some(rating);
    }

    // Function to set the deadline for the learning session
    public entry fun set_session_deadline(learning_session: &mut LearningSession, deadline: u64, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx) || contains(&learning_session.teacher, &tx_context::sender(ctx)), ENotBooked);
        learning_session.sessionDeadline = some(deadline);
    }

    // Function to set the deadline for assignments related to the learning session
    public entry fun set_assignment_deadline(learning_session: &mut LearningSession, deadline: u64, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx) || contains(&learning_session.teacher, &tx_context::sender(ctx)), ENotBooked);
        learning_session.assignmentDeadline = some(deadline);
    }

    // Function to update the deadline for the learning session
    public entry fun update_session_deadline(learning_session: &mut LearningSession, new_deadline: u64, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx) || contains(&learning_session.teacher, &tx_context::sender(ctx)), ENotBooked);
        learning_session.sessionDeadline = some(new_deadline);
    }

    // Function to update the deadline for assignments related to the learning session
    public entry fun update_assignment_deadline(learning_session: &mut LearningSession, new_deadline: u64, ctx: &mut TxContext) {
        assert!(learning_session.student == tx_context::sender(ctx) || contains(&learning_session.teacher, &tx_context::sender(ctx)), ENotBooked);
        learning_session.assignmentDeadline = some(new_deadline);
    }
}
