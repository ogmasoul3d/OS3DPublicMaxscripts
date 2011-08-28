--GenclassID() --generate a new ClassID

plugin simpleObject AnimPlane
name:"AnimPlane"
category:"OS3D"


classID:#(0x368166b5, 0x76ca9690)
(
 parameters main rollout:params 
 (
  totalHeight type:#float ui:totalHeight default:150.0
  heightSegs type:#float ui:heightSegs default:5
  width type:#float ui:width default:15.0
	 
  Znoise type:#float ui:Znoise default:0.0
  WidthNoise type:#float ui:WidthNoise default:0.0
  NoiseSeed type:#integer ui:NoiseSeed default:1337

 )
 
 rollout params "AnimPlane"
 (
  spinner totalHeight"TotalHeight"range:[0,10000,150]
  spinner heightSegs"SegHeight"range:[0.2,1000,100] 
  spinner width"Width"range:[0,10000,15]
	 
  spinner Znoise"Znoise"range:[0,10000,0]
  spinner WidthNoise"WidthNoise"range:[0,10000,0]
  spinner NoiseSeed"Noise Seed"range:[0,10000,1337] type:#integer

 )
 
 on buildMesh do
 (

SegMaxHeight = heightSegs
NewHeight = 0
halfWidth = width / 2.0

vert_array = #()
face_array = #()
tvert_array = #()
vert_count = 2
seed NoiseSeed


undo off -- Turn OFF Undo for polygon creation
(
--mm = mesh numverts:4 name:"DeleteMe"
	
v1 =  [-halfWidth,0,0]
v2 =  [halfWidth,0,0]
append vert_array v1
append vert_array v2
append tvert_array v1
append tvert_array v2
	
while (NewHeight + SegMaxHeight) < TotalHeight do (
vert_count += 2
rndZ = random -Znoise Znoise
rndW = random 0.0 WidthNoise
	
v1 = v3
v2 = v4

NewHeight += SegMaxHeight	
v3 =[-halfWidth - rndW,NewHeight,rndZ]
v4 =[halfWidth + rndW,NewHeight,rndZ]
	

append vert_array v3
append vert_array v4
append tvert_array v3
append tvert_array v4
	
append face_array [vert_count-3,vert_count-2,vert_count]
append face_array [vert_count-3,vert_count,vert_count-1]
	

)

if newHeight != TotalHeight then (
vert_count += 2
rndZ = random -Znoise Znoise
rndW = random 0.0 WidthNoise
v1 = v3
v2 = v4
NewHeight += TotalHeight-NewHeight  
v3 =[-halfWidth - rndW,NewHeight,rndZ]
v4 =[halfWidth + rndW,NewHeight,rndZ]
	

append vert_array v3
append vert_array v4
append tvert_array v3
append tvert_array v4
	
append face_array [vert_count-3,vert_count-2,vert_count]
append face_array [vert_count-3,vert_count,vert_count-1]
)
)--end undo off
setMesh mesh vertices:vert_array faces:face_array tverts:tvert_array

buildTVFaces mesh 

for i = 1 to mesh.numfaces do (setTVFace mesh i (getFace mesh i))



) --end buildmesh

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
   2: (width = abs(gridDist.y))
   3: (totalHeight = abs(gridDist.y))
   4: (#stop)
  )
 )
) --end create
)--end plugin 

