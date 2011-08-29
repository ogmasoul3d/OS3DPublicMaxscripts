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
	SplineIndex type:#integer ui:splineIndex default:1
	totalHeight type:#float ui:totalHeight default:150.0
	heightSegs type:#float ui:heightSegs default:5
	ShapeSteps type:#integer ui:ShapeSteps default:5

	NoiseSeed type:#integer ui:NoiseSeed default:1337
	pObj type:#node ui:pathBtn
	sObj type:#node ui:shapeBtn
	 
	 on pObj get val do
	(
	if val != undefined do (
		--print "get pObj val"
		this.params.pathBtn.text = fancyname val.name this.params.pathBtn
		this.SplineIndex = 1
	)
	val
	)
	
	on SplineIndex get val do (
		--print "SplineIndex set val"
		try (
		cl = (curveLength pObj val)
		this.params.totalHeight.range.y = cl
		this.params.SplineIndex.range.y =  (numsplines val)
		) catch (
			this.params.SplineIndex.range.y = 1
			val = 1
		)
	val	
	)
	
	on sObj get val do
	(
		--print "SObj set val"
		if val != undefined do ( this.params.ShapeBtn.text = fancyname val.name this.params.ShapeBtn)
	val
	)

 )
 
 rollout params "Line Loft"
 (
	spinner SplineIndex"Spline index"range:[1,1,1] type:#integer
	spinner totalHeight"Total Height"range:[0,10000,0.1]
	spinner heightSegs"Seg Height"range:[0.2,1000,100] 
	spinner ShapeSteps"Shape Steps"range:[3,100,5] type:#integer

	spinner NoiseSeed"Noise Seed"range:[0,10000,1337] type:#integer
	 
	pickButton pathBtn "Path" 
	pickButton ShapeBtn "Shape" 

)--end param controller rollout
 	



 on buildMesh do
 (
	if pObj != undefined and sObj != undefined then (
	setMesh mesh verts:#([0,0,0],[totalHeight,0,0],[totalHeight,heightSegs,0],[0,heightSegs,0]) \
    faces:#([3,2,1], [1,4,3])


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
