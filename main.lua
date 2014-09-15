require("pieces")
require("Square")
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
GAME_SPEED = 5 --pps
dt = 0

SCORE = 0
SCORE_CONSTANT = 1005


--Initiate Tetris Piece 
fallingPiece = getRandomTetrisPiece()
fallingPieceColor = getRandomBlockColor()

fallingPieceStartY = -SQUARE_WIDTH*2
fallingPieceStartX = (GRID_WIDTH*SQUARE_WIDTH)/2-(2*SQUARE_WIDTH)

fallingPieceY = fallingPieceStartY
fallingPieceX = fallingPieceStartX

fallingPieceStartRow = 1
fallingPieceStartCol = math.floor(GRID_WIDTH/2)-2

-- fallingPieceRow = fallingPieceStartRow
-- fallingPieceCol = fallingPieceStartCol

fallingPieceRow = fallingPieceStartRow
fallingPieceCol = fallingPieceStartCol

IMAGE_grid_pattern = love.graphics.newImage("resources/grid_pattern.png")
IMAGE_hitmarker = love.graphics.newImage("resources/hitmarker.png")
--IMAGE_snoop = love.graphics.newImage("resources/snoop.gif")

CURRENT_SONG = MUSIC_sandstorm



--##################################################

function love.load()
	snoop = love.graphics.newImage("resources/snoop_square.bmp")
	ANIMATION_snoop = newAnimation(snoop, 290, 595, 0.04, 0)
	


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
			if fallingPieceX == fallingPieceStartX and fallingPieceY == fallingPieceStartY then
				GAME_OVER = true
				CURRENT_SONG:stop()
				MUSIC_violin:play()
			end

			if GAME_OVER == false then
				placeFallingPiece()
				newFallingPiece()
			end
		end

		fallingPieceRow = coordToGrid(fallingPieceY)
		fallingPieceCol = coordToGrid(fallingPieceX)

		SCORE = SCORE+checkFullRows()
	end
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
	for i=1, table.getn(fallingPiece) do
		for j=1, table.getn(fallingPiece[2]) do
			
			if fallingPiece[i][j] == true then
				love.graphics.draw(fallingPieceColor, fallingPieceX+(j*SQUARE_WIDTH), fallingPieceY+(i*SQUARE_WIDTH), 0, SQUARE_SCALE_FACTOR, SQUARE_SCALE_FACTOR)
			end
		end
	end

	for i=1, table.getn(grid) do
		for j=1, table.getn(grid[2]) do

			if grid[i][j].blockColor ~= "NULL" then
				love.graphics.draw(grid[i][j].blockColor, gridToCoordinates(j), gridToCoordinates(i), 0, SQUARE_SCALE_FACTOR, SQUARE_SCALE_FACTOR)

			end
		end
	end

	if weedMode then
		ANIMATION_snoop:draw((GRID_WIDTH*SQUARE_WIDTH)-50,snoopY)
	end

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10) end

function resetGame()
	CURRENT_SONG:play()

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
	fallingPiece = getRandomTetrisPiece()

	fallingPieceRow = fallingPieceStartRow
	fallingPieceCol = fallingPieceStartCol

	fallingPieceX = fallingPieceStartX
	fallingPieceY = fallingPieceStartY

	fallingPieceColor = getRandomBlockColor()
end


function placeFallingPiece()
	print("Placing")
	print("----")
	for i = 1, table.getn(fallingPiece) do
		for j = 1, table.getn(fallingPiece[2]) do
				if fallingPiece[i][j] == true then
					print(i+fallingPieceRow, j+fallingPieceCol)
				grid[i+fallingPieceRow][j+fallingPieceCol].blockColor = fallingPieceColor
			end
		end
	end
	print("------")


	SOUND_hitmarker:play()
end

function moveFallingPiece(dx, dy)
	fallingPieceX = fallingPieceX+dx
	fallingPieceY = fallingPieceY+dy

	if not fallingPieceIsLegal(dx,dy) then
		fallingPieceX = fallingPieceX-dx
	    fallingPieceY = fallingPieceY-dy
	    return false
	end

	return true
end

function fallingPieceIsLegal(dx,dy)
	canMove = true

	for i=1, table.getn(fallingPiece) do
		for j=1, table.getn(fallingPiece[2]) do
			
			if fallingPiece[i][j] == true then

				--print(grid[coordToGrid(fallingPieceY)+i][coordToGrid(fallingPieceX)+j])

				if fallingPieceX+(j*SQUARE_WIDTH) < 0 then
					canMove = false
				elseif fallingPieceX+(j*SQUARE_WIDTH) > (SQUARE_WIDTH*GRID_WIDTH)-1 then
					canMove = false
				elseif fallingPieceY+(i*SQUARE_WIDTH) > (SQUARE_WIDTH*GRID_HEIGHT)-SQUARE_WIDTH then
					canMove = false
				elseif grid[coordToGrid(fallingPieceY)+i][coordToGrid(fallingPieceX)+j].blockColor ~= "NULL" then
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
	oldFallingPiece = fallingPiece

	if fallingPiece == I_PIECE_HORIZ then
		fallingPiece = I_PIECE_VERT
	elseif fallingPiece == I_PIECE_VERT then
		fallingPiece = I_PIECE_HORIZ

	elseif fallingPiece ~= O_PIECE then
		fallingPiece = rotateWithMath()
	end

	--If the move isn't leagal we just reset it
	if not fallingPieceIsLegal(0,0) then
		fallingPiece = oldFallingPiece
	end
end

--Uses matracies and all that fun stuff to rotate a piece
function rotateWithMath()
	oldFallingPiece = fallingPiece

	newFallingPieceWidth = table.getn(oldFallingPiece[2])
	newFallingPieceHeight = table.getn(oldFallingPiece)

	newFallingPieceGrid = {}

	for i = 1, newFallingPieceHeight do
		newFallingPieceGrid[i] ={}
		for j=1, newFallingPieceWidth do
			newFallingPieceGrid[i][j] = false
		end
	end

	for i = 1, newFallingPieceHeight do
		for j=1, newFallingPieceWidth do
			if oldFallingPiece[i][j] == true then
				temp = oldFallingPiece[i][j]

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

	return newFallingPieceGrid
end




-- function fallingPieceIsLegal(drow, dcol)

-- 	canMove = true

-- 	for i=1, table.getn(fallingPiece) do
-- 		for j=1, table.getn(fallingPiece[2]) do
-- 			if fallingPiece[i][j] == true then
-- 				--print(fallingPiece)
-- 				if fallingPieceCol+j < 1 then
-- 					canMove = false
-- 				elseif fallingPieceCol+j > GRID_WIDTH then
-- 					canMove = false
-- 				elseif fallingPieceRow+i < 0 then
-- 					canMove = false
-- 				elseif fallingPieceRow+i > GRID_HEIGHT then
-- 					canMove = false
-- 				elseif grid[fallingPieceRow+i][fallingPieceCol+j].blockColor ~= "NULL" then
-- 					canMove = false
-- 				end
-- 			end
-- 		end
-- 	end

-- 	return canMove
-- end

-- --Moves a piece by a certian amount of rows and columns
-- function moveFallingPiece(drow, dcol)
-- 	--Make the move
-- 	fallingPieceRow = fallingPieceRow + drow
-- 	fallingPieceCol = fallingPieceCol + dcol

-- 	--Check to see if it won't overshoot the board
-- 	if not fallingPieceIsLegal(drow, dcol) then
-- 		--If it does we simply move it back
-- 		fallingPieceRow = fallingPieceRow - drow
-- 		fallingPieceCol = fallingPieceCol - dcol
-- 		return false
-- 	end

-- 	return true

-- end

--##################################################

function gridToCoordinates(gridNum)
	return (gridNum*SQUARE_WIDTH)-SQUARE_WIDTH
end

function coordToGrid(coordVal)
	return math.ceil((coordVal+SQUARE_WIDTH)/SQUARE_WIDTH)
end