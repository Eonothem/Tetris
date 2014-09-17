require("pieces")
require("Square")
require("Piece")
require("audio")
require("math")
require("AnAL")

--UI Scale
GRID_WIDTH = 10
GRID_HEIGHT = 20
SQUARE_WIDTH = 50
SQUARE_SCALE_FACTOR = SQUARE_WIDTH/100

UI_WIDTH = 200 --200

WINDOW_WIDTH = GRID_WIDTH*SQUARE_WIDTH+UI_WIDTH
WINDOW_HEIGHT = GRID_HEIGHT*SQUARE_WIDTH

GAME_OVER = false
GAME_SPEED = 50--pps
dt = 0

SCORE = 0
SCORE_CONSTANT = 1005




IMAGE_grid_pattern = love.graphics.newImage("resources/grid_pattern.png")
IMAGE_hitmarker = love.graphics.newImage("resources/hitmarker.png")
--IMAGE_snoop = love.graphics.newImage("resources/snoop.gif")

CURRENT_SONG = MUSIC_sandstorm

--Orgin is at Row 2 Col 3
offsetX = 3
offsetY = 2


--##################################################

function love.load()
	snoop = love.graphics.newImage("resources/snoop_square.bmp")
	ANIMATION_snoop = newAnimation(snoop, 290, 595, 0.04, 0)
	
	--Initiate Tetris Piece 
	fallingPieceColor = getRandomBlockColor()

	fallingPieceStartY = -SQUARE_WIDTH*2
	fallingPieceStartRow = -1
	fallingPieceStartX = 0--(GRID_WIDTH*SQUARE_WIDTH)/2-(2*SQUARE_WIDTH)
	fallingPieceStartCol = 1

	


	

	piece, name = getRandomTetrisPiece()


	classFallingPiece = Piece(piece, fallingPieceStartX, fallingPieceStartY, name)
	

	--Windows Settings
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
	--Light Blue
	love.graphics.setBackgroundColor(0,170,255)

	resetGame()

end



function love.update(dt)

	--Check Powerups
	checkPowerups(dt)


	

	
	--GAME IS PLAYING
	--fallingPieceY = fallingPieceY+2
	if not GAME_OVER then

		if moveFallingPiece(0,GAME_SPEED) == false then
			

			if classFallingPiece.x == fallingPieceStartX and classFallingPiece.y == fallingPieceStartY then
				GAME_OVER = true
				CURRENT_SONG:stop()
				MUSIC_violin:play()
			end

			if GAME_OVER == false then
				--print("--new--")
				newFallingPiece()
			end
		end

		
		

		SCORE = SCORE+checkFullRows()
	end

	--print(grid[20][3].blockColor)
end

function updateSnoop(dt)
	ANIMATION_snoop:update(dt)

	if ANIMATION_snoop:getCurrentFrame() > 58 then
		ANIMATION_snoop:seek(1)
	end
end

--POWERUPS
--##################################################

function checkPowerups(dt)
	weedModeCheck(dt)
end

weedMode = false
weedModeTimer = 0

snoopY = GRID_HEIGHT*SQUARE_WIDTH


function activateWeedMode()
	CURRENT_SONG:pause()
	MUSIC_weed:play()
	GAME_SPEED = GAME_SPEED/4
	weedMode = true
end

function deactivateWeedMode()
	MUSIC_weed:stop()
	CURRENT_SONG:resume()
	GAME_SPEED = GAME_SPEED*4
	weedMode = false
	weedModeTimer = 0
end

function weedModeCheck(dt)
	weedModeLast = 14

	if weedMode then
		weedModeTimer = weedModeTimer + dt
		snoopY = snoopY-.5
		updateSnoop(dt)
	end

	if weedModeTimer > weedModeLast then
		deactivateWeedMode()
		snoopY = GRID_HEIGHT*SQUARE_WIDTH
	end
end



function checkFullRows()
	newRow = GRID_HEIGHT
	fullRows = 0

	for oldRow=GRID_HEIGHT, 1, -1 do
		rowFull = true
		for j=1, GRID_WIDTH do

			if grid[oldRow][j].blockColor == "NULL" then
				rowFull = false
			end

		end

		if not rowFull then
			grid[newRow] = grid[oldRow]
			newRow = newRow-1

		elseif rowFull then
			fullRows = fullRows + 1

			SOUND_intervention:play()

			

		end
	end

	if fullRows == 1 then
		ONE_ROW_AUDIO[math.random(1, table.getn(ONE_ROW_AUDIO))]:play()
	elseif fullRows == 2 then
		TWO_ROW_AUDIO[math.random(1, table.getn(TWO_ROW_AUDIO))]:play()
	elseif fullRows > 3 then
		THREE_ROW_AUDIO[math.random(1, table.getn(THREE_ROW_AUDIO))]:play()
		SOUND_triple:play()
		SOUND_airhorn:play()
	end

	return (fullRows*fullRows)*SCORE_CONSTANT

end

function love.keypressed(key, isrepeat)
	

	if not GAME_OVER then
		if key == "right" and isrepeat == false then
			moveFallingPiece(SQUARE_WIDTH,0)
		elseif key == "left" and isrepeat == false then
			moveFallingPiece(-SQUARE_WIDTH,0)
		elseif key == "down" and isrepeat == false then
			moveFallingPiece(0, SQUARE_WIDTH)
		elseif key == " " and isrepeat == false then
			rotateFallingPiece()
		elseif key == "w" and isrepeat == false and weedMode == false then
			activateWeedMode()
		end
	end

	if GAME_OVER then

		if key == " " and isrepeat == false then
			resetGame()
			newFallingPiece()
			MUSIC_violin:stop()
			GAME_OVER = false
		end
	end


end



function love.draw()
	

	--Draw grid outline
	love.graphics.draw(IMAGE_grid_pattern, 0, 0 ,0,SQUARE_SCALE_FACTOR,SQUARE_SCALE_FACTOR)

	

	--Draws falling pieces
	for i=1, table.getn(classFallingPiece.blockArr) do
		for j=1, table.getn(classFallingPiece.blockArr[2]) do
			
			if classFallingPiece.blockArr[i][j] == true then
				love.graphics.draw(fallingPieceColor, classFallingPiece.x+(j*SQUARE_WIDTH), classFallingPiece.y+(i*SQUARE_WIDTH), 0, SQUARE_SCALE_FACTOR, SQUARE_SCALE_FACTOR)
			end
		end
	end


	if weedMode then
		ANIMATION_snoop:draw((GRID_WIDTH*SQUARE_WIDTH)-50,snoopY)
	end

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10) end

function resetGame()
	--CURRENT_SONG:play()

	grid = {}

	for i=1, GRID_HEIGHT do
		grid[i] = {}
		for j=1, GRID_WIDTH do
			grid[i][j] = Square("NULL")
		end
	end

	--All of the pieces

	pieces_grid = {}

	for i=1, GRID_HEIGHT do
		pieces_grid[i] = {}
		for j=1, GRID_WIDTH do
			pieces_grid[i][j] = false
		end
	end
end

--##################################################

function newFallingPiece()
	piece, name = getRandomTetrisPiece()

	classFallingPiece.blockArr = piece
	classFallingPiece.name = name

	classFallingPiece.row = fallingPieceStartRow
	classFallingPiece.col = fallingPieceStartCol

	classFallingPiece.x = fallingPieceStartX
	classFallingPiece.y = fallingPieceStartY

	fallingPieceColor = getRandomBlockColor()
end


function moveFallingPiece(dx, dy)
	classFallingPiece.x = classFallingPiece.x+dx
	classFallingPiece.y = classFallingPiece.y+dy

	classFallingPiece.row = coordToGrid(classFallingPiece.y)
	classFallingPiece.col = coordToGrid(classFallingPiece.x)


	

	

	if not fallingPieceIsLegal(dx,dy) then
		classFallingPiece.x = classFallingPiece.x-dx
	    classFallingPiece.y = classFallingPiece.y-dy
	   
	    classFallingPiece.row = coordToGrid(classFallingPiece.y)
		classFallingPiece.col = coordToGrid(classFallingPiece.x)
	    return false
	end

	--print("Row:")
	--print(classFallingPiece.row,coordToGrid(classFallingPiece.y))
	--print("Col:")
	--print(classFallingPiece.col,coordToGrid(classFallingPiece.x))
	--print("-----")

	return true
end

function fallingPieceIsLegal(dx,dy)
	canMove = true

	for i=1, table.getn(classFallingPiece.blockArr) do
		for j=1, table.getn(classFallingPiece.blockArr[2]) do
			
			if classFallingPiece.blockArr[i][j] == true then

				--print(grid[coordToGrid(fallingPieceY)+i][coordToGrid(fallingPieceX)+j])

				if classFallingPiece.x+(j*SQUARE_WIDTH) < 0 then
					canMove = false
				elseif classFallingPiece.x+(j*SQUARE_WIDTH) > (SQUARE_WIDTH*GRID_WIDTH)-1 then
					canMove = false
				elseif classFallingPiece.y+(i*SQUARE_WIDTH) > (SQUARE_WIDTH*GRID_HEIGHT)-SQUARE_WIDTH then
					canMove = false
				elseif grid[classFallingPiece.row+i][classFallingPiece.col+j].blockColor ~= "NULL" then
					print("Row:")
					print(classFallingPiece.row,coordToGrid(classFallingPiece.y))
					print("Col:")
					print(classFallingPiece.col,coordToGrid(classFallingPiece.x))
					print("Contains")
					print (grid[classFallingPiece.row+i][classFallingPiece.col+j].blockColor)
					print("-----")
					canMove = false
				end

			end

		end
	end

	--print(fallingPieceY)
	return canMove
end




--Rotates a piece 
function rotateFallingPiece()
	oldFallingPiece = classFallingPiece

	if classFallingPiece.blockArr == I_PIECE_HORIZ then
		classFallingPiece.blockArr = I_PIECE_VERT
	elseif classFallingPiece.blockArr == I_PIECE_VERT then
		classFallingPiece.blockArr = I_PIECE_HORIZ

	elseif classFallingPiece.blockArr ~= O_PIECE then
		classFallingPiece.blockArr = rotateWithMath()
	end

	--If the move isn't leagal we just reset it
	if not fallingPieceIsLegal(0,0) then
		fallingPiece.blockArr = oldFallingPiece.blockArr
	end
end

--Uses matracies and all that fun stuff to rotate a piece
function rotateWithMath()
	oldFallingPiece = classFallingPiece

	newFallingPieceWidth = table.getn(oldFallingPiece.blockArr[2])
	newFallingPieceHeight = table.getn(oldFallingPiece.blockArr)

	newFallingPieceGrid = {}

	for i = 1, newFallingPieceHeight do
		newFallingPieceGrid[i] ={}
		for j=1, newFallingPieceWidth do
			newFallingPieceGrid[i][j] = false
		end
	end

	for i = 1, newFallingPieceHeight do
		for j=1, newFallingPieceWidth do
			if oldFallingPiece.blockArr[i][j] == true then
				temp = oldFallingPiece.blockArr[i][j]

				pivotY = 2
				pivotX = 3
			
				y = i - pivotY
				x = j - pivotX

				newCol = -y
				newRow = x

				newColAdd = newCol + pivotX
				newRowAdd = newRow + pivotY


				newFallingPieceGrid[newRowAdd][newColAdd] = temp
			end
		end
	end

	for i = 1, newFallingPieceHeight do
		for j=1, newFallingPieceWidth do
				if newFallingPieceGrid[i][j] then
					io.write("1 ")
				else
					io.write("0 ")
				end
		end
		print()
	end
	print(classFallingPiece.name)
	print("-------")

	return newFallingPieceGrid
end

--##################################################

function gridToCoordinates(gridNum)
	return (gridNum*SQUARE_WIDTH)-SQUARE_WIDTH
end

function coordToGrid(coordVal)
	return math.ceil((coordVal+SQUARE_WIDTH)/SQUARE_WIDTH)
end