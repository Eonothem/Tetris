math.randomseed(os.time())

T_PIECE = {{false, false, true, false},
		   {false, true, true, true},
		   {false, false, false, false},
		   {false, false, false, false}}

J_PIECE = {{false, false, false, false},
		   {false, true, true, true},
		   {false, false, false, true},
		   {false, false, false, false}}

L_PIECE  = {{false, false, false, false},
		   {false, true, true, true},
		   {false, true, false, false},
		   {false, false, false, false}}


S_PIECE = {{false, false, false, false},
		  		 {false, false, true, true},
		   		 {false, true, true, false},
		   		 {false, false, false, false}}


Z_PIECE = {{false, false, false, false},
		  		 {false, true, true, false},
		   		 {false, false, true, true},
		   		 {false, false, false, false}}

--####################

O_PIECE = {{false, false, false, false},
		   {false, true, true, false},
		   {false, true, true, false},
		   {false, false, false, false}}

--####################

I_PIECE_HORIZ = {{false,false,false,false}, 
		  	     {true, true, true, true},
		  		 {false,false,false,false},
		  		 {false,false,false,false}}

I_PIECE_VERT = {{false, false, true, false}, 
		  	    {false, false, true, false},
		  		{false, false, true, false},
		  		{false, false, true, false}}


IMAGE_block_red = love.graphics.newImage("resources/block_red.png")
IMAGE_block_green = love.graphics.newImage("resources/block_green.png")


TETRIS_PIECES = {T_PIECE, I_PIECE_HORIZ, J_PIECE, L_PIECE, O_PIECE, S_PIECE, Z_PIECE}
PIECE_COLORS = {IMAGE_block_red, IMAGE_block_green}

TETRIS_PIECE_SIZE = table.getn(TETRIS_PIECES)
PIECE_COLOR_SIZE = table.getn(PIECE_COLORS)

function getRandomTetrisPiece()
	return TETRIS_PIECES[math.random(1,TETRIS_PIECE_SIZE)]
end

function getRandomBlockColor()
	return PIECE_COLORS[math.random(1,PIECE_COLOR_SIZE)]
end