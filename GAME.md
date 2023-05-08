# GAME IMPLEMENTATION

## Data Structures

#### Pieces

Each piece contains the following information:

  * `pos` - the position of the piece in the cells array
  * `team` - the team the piece belongs to
  * `status` - the status of the piece
    - `in play` - the piece is in play
    - `in reserve` - the piece is in reserve
    - `in victory zone` - the piece is in the victory zone
    - `in goal` - the piece is in the goal

#### Cells

Each Cells contains the following information:

  * `coords` - the coordinates of the cell
  * `amount` - the amount of pieces in the cell
  * `team` - the team the pieces belong to
  * `cell type` - the type of cell
    - `normal` - the cell is a normal cell
    - `goal` - the cell is a goal cell
    - `victory zone` - the cell is a victory zone cell
    - `reserve` - the cell is a reserve cell
    - `wall` - the cell is a wall celll

#### Teams

Each team contains the following information:

  * `team` - the team number
  * `reserve` - the reserve cell of the team
  * `victory zone` - the victory zone cell of the team
  * `goal` - the goal cell of the team
  * `selected` - the selected piece of the teasm

#### Player

Each player contains the following information:

  * `team` - the team number of the player
  * `status` - the status of the player
    - `in game` - the player is in game
    - `winner` - the player is the winner
    - `blocked` - the player is blocked