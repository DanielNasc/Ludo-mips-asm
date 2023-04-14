# GAME IMPLEMENTATION

## Data Structures

#### Pieces

Each piece contains the following information:

  * `color` - the color of the piece
  * `coords` - the coordinates of the piece
  * `team` - the team the piece belongs to
  * `status` - the status of the piece
    - `dead` - the piece is dead
    - `in play` - the piece is in play
    - `in reserve` - the piece is in reserve
    - `in victory zone` - the piece is in the victory zone
    - `in goal` - the piece is in the goal
  
As the game board is a 128x128 matrix, X and Y can be represented by a number between 0 and 127 (0 - 0x7F).
The `team` is represented by a number between 0 and 3 (0 - 0x03) or 2 bits.
The `status` is represented by a number between 0 and 4 (0 - 0x04) or 3 bits.
The `color` is represented by a number between 0 and 3 (0 - 0x03) or 2 bits.


With this information, we can represent the piece as a 32-bit word.
From less significant to most significant bits:

    * 7 bits for X coordinate -> 128 possible values between 0 and 127
    * 7 bits for Y coordinate -> 128 possible values between 0 and 127
    * 2 bits for team -> 4 possible values between 0 and 3
    * 3 bits for status -> 8 possible values between 0 and 7
    * 2 bits for color  -> 4 possible values between 0 and 3
    * TOTAL USED BITS: 21
