struct team {
    int selected; // 2
    int color;
};

// [ Piece Piece Piece Piece Piece Piece Piece Piece Piece Piece Piece Piece ]
struct piece {
    int cell;
    int team;
    int status;
};

// [ CELL CELL CELL CELL CELL CELL CELL ]
struct cell {
    int coord;
    int amount;
    int team;
    int cell
};
