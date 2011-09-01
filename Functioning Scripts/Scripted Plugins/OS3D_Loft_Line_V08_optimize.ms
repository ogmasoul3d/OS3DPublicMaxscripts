--GenclassID() --generate a new ClassID

plugin simpleObject LineLoft
name:"Line Loft"
category:"OS3D"


classID:#(0x63d4180e, 0x132b1f4a)
(
fn fancyname inputName callerNode= (
newName = (callerNode.name + ": " + inputName)
return newName	
)
 parameters main rollout:params 
 (
	numSplinesInPath type:#integer
	SplineIndex type:#integer ui:splineIndex default:2
	totalHeight type:#float ui:totalHeight default:1.0
	heightSegs type:#float ui:heightSegs default:0.02
	ShapeSteps type:#integer ui:ShapeSteps default:6

	NoiseSeed type:#integer ui:NoiseSeed default:1337
	pObj type:#node ui:pathBtn
	pObjName type:#string default:"Path"
	sObj type:#node ui:shapeBtn
	sObjName type:#string default:"Shape"
 )
 rollout params "Line Loft"
 (
	spinner SplineIndex"Spline index"range:[1,10000,1] type:#integer
	spinner totalHeight"Height"range:[0.001,1.000,0.500]
	spinner heightSegs"Seg Height"range:[0,1,.1]  scale:0.001
	spinner ShapeSteps"Shape Steps"range:[3,100,5] type:#integer

	spinner NoiseSeed"Noise Seed"range:[0,10000,1337] type:#integer
	 
	pickButton pathBtn "Path" 
	pickButton ShapeBtn "Shape" 
	
	on params open do (
	pathBtn.text = pObjName
	ShapeBtn.text = sObjName
	)
	
	on pathBtn picked obj do
	(
		SplineIndex.value = 1
		pObjName = ("Path: " + obj.name)
		pathBtn.text = pObjName
			if classof obj == line then (
			print "this is a line object"
			numSplinesInPath = (numsplines obj)
			SplineIndex.range.y = numSplinesInPath
			) else (
				tmpCpy = convertToSplineShape (copy obj)
				print "this is not a shape of class line"
				numSplinesInPath = (numsplines tmpCpy)
				SplineIndex.range.y = numSplinesInPath
				this.SplineIndex = 1
				delete tmpCpy
			)
	)
	
	on ShapeBtn picked obj do
	(
		sObjName = ("Shape:" + obj.name)
		ShapeBtn.text = sObjName
	)
)--end param controller rollout
 	

 on buildMesh do
 (
	if pObj != undefined and sObj != undefined then (
		MaxLength = 1.0 -- curveLength pObj 1
		NewHeight = 0 --Just a counterVal			
		pathSteps = 0
		PathStepVal = heightSegs  --if you go to 1.0 the tangent is "wrong..."
		ShapeStepVal = 1.0 / shapeSteps --if you go to 1.0 the tangent is "wrong..."

		Vertex_Array = #()
		Shape_vertex_Array = #()
		face_array = #()
		
		Counter = 0
		ps = 0

		--precalc the verts on the shape spline to save calc time 
		
		for ss = 0 to (ShapeSteps-1) do (
				Counter += 1
				PosOnPath = lengthInterp sObj 1 (ss*ShapeStepVal) steps:100
				STangOnPath = lengthTangent sObj 1 (ss*ShapeStepVal) steps:100
				SobjLocalPos = PosOnPath * (inverse sObj.transform)
				Shape_vertex_Array[Counter] = SobjLocalPos
		)
		
		Counter = 0
		
		--While loop that build the main loft
		while (NewHeight + heightSegs) < TotalHeight do (
		Ps += 1
		pathSteps += 1
		NewHeight += PathStepVal
			
		PosOnPath = lengthInterp pObj SplineIndex (NewHeight) steps:1000
		TangOnPath = lengthTangent pObj SplineIndex (NewHeight) steps:1000
		PathMatrix = matrixFromNormal TangOnPath

		Zaxis = (normalize TangOnPath)
		TheX = Normalize (cross Zaxis [0,0,1] )
		TheY = Normalize (cross Zaxis TheX )

		NewTm = matrix3  TheX -TheY Zaxis PosOnPath
			ss = 1
			for ss = 1 to (ShapeSteps) do (
				Counter += 1
				Vertex_Array[Counter] = (Shape_vertex_Array[ss] * NewTm)--(SobjLocalPos * NewTm)
			)
		)

		--Finishing segment that can have variable seg length
		if newHeight != TotalHeight then (
		pathSteps += 1
		Ps += 1
		NewHeight = TotalHeight
		PosOnPath = lengthInterp pObj SplineIndex (NewHeight) steps:1000
		TangOnPath = lengthTangent pObj SplineIndex (NewHeight) steps:1000
		PathMatrix = matrixFromNormal TangOnPath

		Zaxis = (normalize TangOnPath)
		TheX = Normalize (cross Zaxis [0,0,1] )
		TheY = Normalize (cross Zaxis TheX )

		NewTm = matrix3  TheX -TheY Zaxis PosOnPath
			ss = 1
			for ss = 1 to (ShapeSteps) do (
				Counter += 1
				-- Taper scale	
			--	ScaleM = scaleMatrix [((NewHeight)+.1),((NewHeight)+.1) ,((NewHeight)+.1)  ]
			--   SobjLocalPos *= ScaleM
				--Vertex_Array[Counter] = (SobjLocalPos * NewTm)
				Vertex_Array[Counter] = (Shape_vertex_Array[ss] * NewTm)
			)
		)	

			undo off (
			for ps = 0 to (PathSteps-2) do (
			--format "=== heightseg: %\n" hs 	
				
				for ss = 1 to (ShapeSteps) do (
						
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
		--			format " %  -- 1_FACE %  %  %     \n" side (x0 + y0) (x1+y0)  (x0 + y1) 
		--			format " %  -- 2_FACE %  %  %   \n\n" side (x0 + y1)  (x1+y0)   (x1 + y1)
					
					append face_array [(x1+y0) , (x0 + y0), (x0 + y1) ]
					append face_array  [(x1+y0),(x0 + y1),(x1 + y1) ]
					
				)
			)
		setMesh mesh verts:Vertex_Array faces:face_array
		)
	) --end if pObj != undefined and sObj != undefined then
	
) --end buildmesh

tool create (
 on mousePoint click do
 (
  case click of
  (
   1: coordsys grid (nodeTM.translation = gridPoint)
  )
 )
 on mouseMove click do
 (
  case click of
  (
	 2: (#stop)
   --2: (heightSegs = abs(gridDist.y))
   --3: (totalHeight = abs(gridDist.y))
   --4: (#stop)
  )
 )
) --end create
)--end plugin 
