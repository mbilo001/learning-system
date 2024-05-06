# Decentralized Learning System Module Documentation
## Overview
The Decentralized Learning System module facilitates the booking, scheduling, management, and dispute resolution of learning sessions between students and teachers in a decentralized manner. This module ensures transparency, fairness, and security in the learning process by leveraging blockchain technology.

## Struct Definitions
### LearningSession
- **Fields**:
  - `id`: Unique identifier for the learning session.
  - `student`: Address of the student who booked the session.
  - `teacher`: Optional address of the teacher assigned to the session.
  - `description`: Brief description of the learning session.
  - `learning_objectives`: Goals or objectives of the learning session.
  - `materials`: Learning materials such as documents, links, videos, etc.
  - `price`: Price set for the learning session.
  - `escrow`: Balance of funds held in escrow for the session.
  - `sessionScheduled`: Indicates if the session has been scheduled.
  - `dispute`: Indicates if there's a dispute for the session.
  - `progress`: Progress of the session (0-100%).
  - `feedback`: Optional feedback provided by the student.
  - `rating`: Optional rating provided by the student.
  - `sessionDeadline`: Optional deadline for the learning session.
  - `assignmentDeadline`: Optional deadline for assignments related to the session.

## Entry Functions
### `book_learning_session`
- **Purpose**: Allows a student to book a learning session with a teacher.
- **Parameters**:
  - `description`: Brief description of the learning session.
  - `learning_objectives`: Goals or objectives of the learning session.
  - `materials`: Learning materials such as documents, links, videos, etc.
  - `price`: Price set for the learning session.
  - `ctx`: Transaction context.
- **Possible Errors**:
  - `EInvalidBooking`: If the session is already booked.

### `request_learning_session`
- **Purpose**: Allows a teacher to accept a request for a learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `ctx`: Transaction context.
- **Possible Errors**:
  - `EInvalidSession`: If the session is not valid.

### `submit_learning_session`
- **Purpose**: Marks a learning session as scheduled.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `ctx`: Transaction context.

### `dispute_learning_session`
- **Purpose**: Allows a student to dispute a learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `ctx`: Transaction context.
- **Possible Errors**:
  - `EDispute`: If the session is not valid.

### `resolve_learning_session`
- **Purpose**: Resolves a dispute for a learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `resolved`: Boolean indicating if the dispute is resolved.
  - `ctx`: Transaction context.
- **Possible Errors**:
  - `EDispute`: If the session is not valid.
  - `EAlreadyResolved`: If the dispute is already resolved.

### `release_payment`
- **Purpose**: Releases payment for a scheduled learning session to the teacher.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `ctx`: Transaction context.
- **Possible Errors**:
  - `ENotBooked`: If the session is not booked.
  - `EInvalidSession`: If the session is not valid.
  - `EInvalidBooking`: If the session is not booked by the sender.

### `add_funds_to_session`
- **Purpose**: Allows a student to add funds to a learning session's escrow.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `amount`: Amount of funds to add.
  - `ctx`: Transaction context.
- **Possible Errors**:
  - `ENotBooked`: If the session is not booked by the sender.

### `request_refund`
- **Purpose**: Allows a student to request a refund for a learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `ctx`: Transaction context.
- **Possible Errors**:
  - `ENotBooked`: If the session is not booked by the sender.
  - `EInvalidWithdrawal`: If the session is already scheduled.

### `mark_session_complete`
- **Purpose**: Marks a learning session as complete.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `ctx`: Transaction context.
- **Possible Errors**:
  - `ENotBooked`: If the session is not booked by the sender.

### `cancel_learning_session`
- **Purpose**: Allows either the student or the teacher to cancel a learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `ctx`: Transaction context.

### `update_session_description`
- **Purpose**: Allows the student to update the description of the learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `new_description`: New description for the session.
  - `ctx`: Transaction context.

### `update_session_price`
- **Purpose**: Allows the student to update the price of the learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `new_price`: New price for the session.
  - `ctx`: Transaction context.

### `provide_feedback`
- **Purpose**: Allows the student to provide feedback for the completed session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `feedback`: Feedback provided by the student.
  - `ctx`: Transaction context.
- **Possible Errors**:
  - `ENotBooked`: If the session is not booked by the sender.
  - `ENotScheduled`: If the session is not yet scheduled.

### `provide_rating`
- **Purpose**: Allows the student to provide a rating for the completed session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `rating`: Rating provided by the student.
  - `ctx`: Transaction context.
- **Possible Errors**:
  - `ENotBooked`: If the session is not booked by the sender.
  - `ENotScheduled`: If the session is not yet scheduled.

### `set_session_deadline`
- **Purpose**: Sets the deadline for the learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `deadline`: Deadline for the session.
  - `ctx`: Transaction context.

### `set_assignment_deadline`
- **Purpose**: Sets the deadline for assignments related to the learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `deadline`: Deadline for assignments.
  - `ctx`: Transaction context.

### `update_session_deadline`
- **Purpose**: Updates the deadline for the learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `new_deadline`: New deadline for the session.
  - `ctx

`: Transaction context.

### `update_assignment_deadline`
- **Purpose**: Updates the deadline for assignments related to the learning session.
- **Parameters**:
  - `learning_session`: Reference to the learning session object.
  - `new_deadline`: New deadline for assignments.
  - `ctx`: Transaction context

This documentation provides an overview of the Decentralized Learning System module, including its struct definitions, entry functions, and additional functions. Additional functions will be documented as needed.