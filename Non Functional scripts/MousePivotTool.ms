fn getBoundningBoxSize inputNode = (

	bb = nodeGetBoundingBox inputNode inputNode.transform
	minPos = bb[1]
	maxPos = bb[2]
	xSize = in coordsys inputNode abs (minPos.x - maxPos.x)	
	ySize = abs (minPos.y - maxPos.y)	
	zSize = abs (minPos.z - maxPos.z)	
	
	return #(xSize,ySize, zSize)
)

fn CreateBoundingBox inputNode = (
	theSize = getBoundningBoxSize inputNode
	b = box width:theSize[1] Length:theSize[2] Height:theSize[3] lengthsegs:2 widthsegs:2 heightsegs:2 pos:inputNode.pos
	b.transform = inputNode.transform
	
	bbBox = nodeLocalBoundingBox b
	bbInput = nodeLocalBoundingBox inputNode
	
	b.pos += ( bbInput[1] - bbBox[1])
	b.parent = inputNodey
	b.wirecolor = [200,200,200] as color
	b.backFaceCull = true
	b.xray = true
	b.isFrozen = true
	b = (convertToMesh b)
	return b
)

fn compareFN v1 v2 = (
local d = v1.DistanceFrom - v2.DistanceFrom
	case of
	(
	(d < 0.): -1
	(d > 0.): 1
	default: 0
	)
)

fn PixelPos inputPoint3D =
(
screen_width = 0
screen_height = 0
ViewSize = getViewSize()

screen_width=ViewSize.x as float
screen_height=ViewSize.y as float

--viewport.setTM ViewTransform
thePos = inputPoint3D * viewport.getTM()
screen_origin = mapScreenToView [0,0] (thePos.z) [screen_width,screen_height]
end_screen = mapScreenToView [screen_width,screen_height] (thePos.z) [screen_width , screen_height]
	
world_size = screen_origin-end_screen
x_aspect =screen_width/(abs world_size.x)
y_aspect =screen_height/(abs world_size.y)

screen_coords = point2 (x_aspect*(thePos.x-screen_origin.x)) (-(y_aspect*(thePos.y-screen_origin.y)))

return screen_coords
)

struct DistanceVert (VertID, DistanceFrom, screenPos)


fn DrawViewportMarker theBBNode = (
		gw.resetUpdateRect() 
	returnVal = theBBNode.pos

		numv = meshop.getnumverts theBBNode
		faceArray=#()
	
		for f = 1 to (theBBNode.numfaces) do (
			in coordsys (inverse (viewport.GetTM())) theFN = getFaceNormal theBBNode f
			if theFN.z > 0 then append faceArray f --if Z is negative, add to array
		)
		
		vertsSel = meshop.getVertsUsingFace theBBNode (faceArray as bitarray)
		ClickedOnArray = #()
		for v in (vertsSel as array) do (

			thePos = PixelPos (meshop.getVert theBBNode v)
			TheDistance = distance  mouse.pos thePos 
				if TheDistance < 15.0 then (
				TheValue = DistanceVert VertID:v DistanceFrom:TheDistance screenPos:thePos

				append ClickedOnArray theValue
				)
			
			if ClickedOnArray.count >= 1 then (
			qsort ClickedOnArray compareFN
			
			Closestpos = ClickedOnArray[1].screenpos
			returnVal = (meshop.getVert theBBNode ClickedOnArray[1].VertID)
			gw.wMarker [Closestpos.x,Closestpos.y,100] ("circle" as name)
			
			)
			
		)
		
		gw.enlargeUpdateRect #whole

		gw.updateScreen()
return returnVal
)



tool IKEAPivotTool
(

local TheInputNode
local bbNode
local selPos
	
on start do (
TheSel = (selection as array)
	if TheSel.count == 1 then ( 
	TheInputNode = TheSel[1]
	print TheInputNode.name
	bbNode =  ( (CreateBoundingBox TheInputNode))
	print bbNode.name
	selPos = TheInputNode.pos
	)
)

on mousePoint clickno do ( 
	thePos = DrawViewportMarker bbNode
	TheInputNode.pivot = thePos
	)

on freeMove  do (
	thePos = DrawViewportMarker bbNode
	--print thePos
	
	) --b.pos = worldPoint
	
on mouseAbort args do (
	delete bbNode
	)
)

startTool IKEAPivotTool