require("class")
Piece = class(function(pc, blockArr, x, y, name)
				pc.blockArr = blockArr
				pc.x = x
				pc.y = y
				pc.name = name
			end)
