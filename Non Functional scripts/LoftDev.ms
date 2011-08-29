pObj = $path
sObj = $shape
pathSteps = 0
shapeSteps = 0
Vertex_Array = #()
delete $deleteMe*

if pObj != undefined and sObj != undefined then (
	
MaxLength = 1.0 -- curveLength pObj 1
TotalHeight = .8
SegMaxHeight = .01
NewHeight = 0 --Just a counterVal
	
pathSteps = 0
PathStepVal = (TotalHeight / SegMaxHeight) / MaxLength --if you go to 1.0 the tangent is "wrong..."
shapeSteps = 25
ShapeStepVal = 0.99 / shapeSteps --if you go to 1.0 the tangent is "wrong..."

Vertex_Array = #()
Counter = 0
ps = 0

--While loop that build the main loft
while (NewHeight + SegMaxHeight) < TotalHeight do (
Ps += 1
pathSteps += 1
NewHeight += PathStepVal
print ("newHeight: " + NewHeight as string)
	
PosOnPath = lengthInterp pObj 1 (NewHeight) steps:100
TangOnPath = lengthTangent pObj 1 (NewHeight) steps:100
PathMatrix = matrixFromNormal TangOnPath

Zaxis = (normalize TangOnPath)
TheX = Normalize (cross Zaxis [0,0,1] )
TheY = Normalize (cross Zaxis TheX )

NewTm = matrix3  TheX -TheY Zaxis PosOnPath
	ss = 1
	for ss = 0 to (ShapeSteps-1) do (
		Counter += 1
		PosOnPath = lengthInterp sObj 1 (ss*ShapeStepVal) steps:100
		STangOnPath = lengthTangent sObj 1 (ss*ShapeStepVal) steps:100
		
		SobjLocalPos = PosOnPath * (inverse sObj.transform)

		
		-- Taper scale	
		ScaleM = scaleMatrix [((NewHeight)+.1),((NewHeight)+.1) ,((NewHeight)+.1)  ]
		SobjLocalPos *= ScaleM
		Vertex_Array[Counter] = (SobjLocalPos * NewTm)
		
	)
)

--Finishing segment that can have variable seg length
if newHeight != TotalHeight then (
pathSteps += 1
Ps += 1
NewHeight += TotalHeight-PathStepVal
PosOnPath = lengthInterp pObj 1 (ps*PathStepVal) steps:100
TangOnPath = lengthTangent pObj 1 (ps*PathStepVal) steps:100
PathMatrix = matrixFromNormal TangOnPath

Zaxis = (normalize TangOnPath)
TheX = Normalize (cross Zaxis [0,0,1] )
TheY = Normalize (cross Zaxis TheX )

NewTm = matrix3  TheX -TheY Zaxis PosOnPath
	ss = 1
	for ss = 0 to (ShapeSteps-1) do (
		Counter += 1
		PosOnPath = lengthInterp sObj 1 (ss*ShapeStepVal) steps:100
		STangOnPath = lengthTangent sObj 1 (ss*ShapeStepVal) steps:100
		
		SobjLocalPos = PosOnPath * (inverse sObj.transform)
		
		-- Taper scale	
		ScaleM = scaleMatrix [((ps*PathStepVal)+.1),((ps*PathStepVal)+.1) ,((ps*PathStepVal)+.1)  ]
		SobjLocalPos *= ScaleM
		Vertex_Array[Counter] = (SobjLocalPos * NewTm)
		
	)
)	
		

)

------Build mesh

undo off -- Turn OFF Undo for polygon creation
(
	mm = mesh numverts:Vertex_Array.count name:"DeleteMe"
	for v = 1 to Vertex_Array.count do (
		meshop.setvert mm v Vertex_Array[v]
	)
	
	for ps = 0 to (PathSteps-3) do (
	--format "=== heightseg: %\n" hs 	
		
		for ss = 1 to (ShapeSteps-1) do (
				
			x0 = ss
			x1 = ss +1
			y0 = ps * (ShapeSteps )
			y1 = (ps+1)*(ShapeSteps )
		
			if ss == (ShapeSteps) then (
		--		format "\n"
				x1 -= (ss) 
				
				--this is neccecary since we want to set the last 
				--poly in every segemt to connect to the first vertex again
			)
--			format " %  -- POLY %  %  %  %   \n" side (x0 + y0) (x1+y0) (x1 + y1) (x0 + y1) 
			format " %  -- 1_FACE %  %  %     \n" side (x0 + y0) (x1+y0)  (x0 + y1) 
			format " %  -- 2_FACE %  %  %   \n\n" side (x0 + y1)  (x1+y0)   (x1 + y1)

			--meshop.createPolygon mm #( (x0 + y0),(x0 + y1),(x1 + y1), (x1+y0)   )  --create 4sided poly
			meshop.createPolygon mm #( (x1+y0) , (x0 + y0), (x0 + y1) ) --face 1
			meshop.createPolygon mm #(  (x1+y0),(x0 + y1),(x1 + y1) ) --face 2
			
		)
	)
	
	update mm
	mm.wirecolor = gray
)--end undo off
