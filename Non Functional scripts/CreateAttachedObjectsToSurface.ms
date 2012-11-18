delete $deleteMe_*

BaseObj = $Plane001
objArray = $Box001_* as array
toMeshMod = (Turn_to_Mesh())
--addModifier BaseObj toMeshMod

item = objArray[1]
for item in objArray do (

	Start = item.pos + ([0,0,1] * item.dir)
	TheRay = ray Start (-item.dir)
	
-- 	sp1 = sphere name:"deleteMe_" pos:StartPoint radius:2
-- 	sp2 = sphere name:"deleteMe_" pos:EndPoint radius:2
	arr = intersectRayEx BaseObj TheRay
	
	--sphere name:"deleteMe_" pos:arr[1].pos radius:2
	if arr != undefined then (
	attachObj = point name:"deleteMe_" 
	
	actrl = Attachment() --create an Attachment controller
	attachObj.position.controller = actrl --assign to the position of the geosphere
	actrl.node = BaseObj --set the cylinder as the node to attach to
	addNewKey actrl 0f --add a key at frame 0
	theAKey = AttachCtrl.getKey actrl 1--get the first key
	--Set the face index (0-based) by reading the number of faces in the mesh
	--The last face of a cylinder is always on top near the central vertex!
	theAKey.face = arr[2]-1
	--Set the coordinates for the center.
	--The barycentric coordinates of the central vertex are [1,0]
	theAKey.coord = [arr[3].x, arr[3].y]
	
	item.parent = attachObj
	) else (
	print "intersectRayEx = undefined"	
	)
)
hide $deleteMe_*
--select $Box001_*
--DeleteModifier BaseObj toMeshMod
