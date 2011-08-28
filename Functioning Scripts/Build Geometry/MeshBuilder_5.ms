/*
Created by Anton Berg - OgmaSoul3D 
www.os3d.se

This small script creates a cylinder without any capping...

this is a useful testbench for people trying to program there
own custom objects...
*/

PointArray = ($point* as array)
delete $DeleteMe*

heightSegs = 	50
totalHeight = 100.0
sides = 12
VertArray =#()
heightPerSeg = (totalHeight / heightSegs)
radius = 15.0
count = 1

for z = 0 to heightSegs do (
	
	for i = 1 to sides do (
		TheVal = 360/sides
		xpos = cos(theVal * i) *  (radius )
		ypos = sin(theVal * i) *  (radius )
		zpos = heightPerSeg * z
		thePos =  [xpos,ypos,zpos]
		thePos.x += (sin (z*36.0))*1.0
		thePos.y += (cos (z*36.0))*1.0
		VertArray[count] = thePos
		
		count += 1
		)
	
)



undo off -- Turn OFF Undo for polygon creation
(
	mm = mesh numverts:VertArray.count name:"DeleteMe"
	for v = 1 to VertArray.count do (
		meshop.setvert mm v vertArray[v]
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
			format " %  -- 2_FACE %  %  %   \n\n" side (x0 + y1)  (x1+y0)   (x1 + y1)
			*/
			
			--meshop.createPolygon mm #( (x0 + y0), (x1+y0), (x1 + y1), (x0 + y1) )  --create 4sided poly
			meshop.createPolygon mm #( (x0 + y0), (x1+y0) , (x0 + y1) ) --face 1
			meshop.createPolygon mm #(  (x0 + y1),  (x1+y0),   (x1 + y1) ) --face 2
			
		)
	)
	
	update mm
)--end undo off