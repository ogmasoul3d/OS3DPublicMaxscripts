--GenclassID() --generate a new ClassID

plugin simpleObject ThreadCyl
name:"ThreadCyl"
category:"OS3D"


classID:#(0x3b7ee57e, 0x5818d2a0)
(
 parameters main rollout:params 
 (
  totalHeight type:#float ui:totalHeight default:150.0
  heightSegs type:#integer ui:heightSegs default:5
  Sides type:#integer ui:sides default:4
  radius type:#float ui:radius default:15.0
  offset type:#float ui:offset default:15.0  
 )
 
 rollout params "ThreadCyl"
 (
  spinner totalHeight"TotalHeight"range:[0,10000,150]
  spinner heightSegs"# HeightSegs"range:[2,1000,100] type:#integer
  spinner sides"# Sides"range:[3,1000,6] type:#integer
  spinner radius"Radius"range:[1,10000,15]
  spinner offset"Offset"range:[0,10000,0]
 )
 
 on buildMesh do
 (
	-- mm = mesh numverts:VertArray.count name:"DeleteMe"
	vert_array = #()
	face_array = #()
	vert_count = 0
	count = 1
	heightPerSeg = (totalHeight / heightSegs)
	 
	for z = 0 to heightSegs do (
	
	for i = 1 to sides do (
		TheVal = 360/sides
		xpos = cos(theVal * i) *  (radius )
		ypos = sin(theVal * i) *  (radius)
		zpos = heightPerSeg * z
		thePos =  [xpos,ypos,zpos]
		thePos.x += ((sin (z*36.0))*offset)
		thePos.y += ((cos (z*36.0))*offset)
		vert_array[count] = thePos
		
		count += 1
		)
	
	)
	
	
	for hs = 0 to (heightSegs-1) do (
	--format "=== heightseg: %\n" hs 	
		
	for side = 1 to (sides) do (
				
			x0 = side
			x1 = side +1
			y0 = hs * (sides )
			y1 = (hs+1)*(sides )
		
			if side == (sides) then (
		--		format "\n"
				x1 -= (side) 
				
				--this is neccecary since we want to set the last 
				--poly in every segemt to connect to the first vertex again
			)
		
			/*
			format " %  -- POLY %  %  %  %   \n" side (x0 + y0) (x1+y0) (x1 + y1) (x0 + y1) 
			format " %  -- 1_FACE %  %  %     \n" side (x0 + y0) (x1+y0)  (x0 + y1) 
			*/
			--format " %  -- 2_FACE %  %  %   \n\n" side (x0 + y1)  (x1+y0)   (x1 + y1)
			
			--								  v1	       v2        v3           v4
			--meshop.createPolygon mm #( (x0 + y0), (x1+y0), (x1 + y1), (x0 + y1) )  --create 4sided poly
			--meshop.createPolygon mm #( (x0 + y0), (x1+y0) , (x0 + y1) ) --face 1
			--meshop.createPolygon mm #(  (x0 + y1),  (x1+y0),   (x1 + y1) ) --face 2

-- 			v1 = (x0 + y0)
-- 			v2 = (x1+y0)
-- 			v3 = (x1 + y1) 
-- 			v4 = (x0 + y1)
 
			append face_array [(x0 + y1) ,(x1+y0),(x1 + y1)]
			append face_array [ (x0 + y0), (x1+y0) , (x0 + y1) ]
			vert_count += 4
			
		)
	)
	--print vert_array
	 setMesh mesh verts:vert_array faces:face_array
	--update mm
 ) --end os3d build mesh
 
tool create
(
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
   2: (radius = abs(gridDist.y))
   3: (totalHeight = abs(gridDist.y))
   4: (#stop)
  )
 )
) --end create
)--end plugin 