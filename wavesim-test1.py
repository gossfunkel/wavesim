from direct.showbase.ShowBase import ShowBase
from panda3d.core import Shader, loadPrcFileData, GeomVertexArrayFormat, GeomVertexFormat, GeomVertexData
from panda3d.core import GeomVertexWriter, Geom, GeomNode, GeomPoints, GeomVertexReader, LVecBase3f
from math import floor, sin, sqrt
import numpy as np

config_vars = """
win-size 1200 800
show-frame-rate-meter 1
hardware-animated-vertices true
basic-shaders-only false
threading-model Cull/Draw
"""
loadPrcFileData("", config_vars)

t = 0.0

def coul(r,q1,q2):
	# cast charges to floats since F may take non-integer values
	q1 = float(q1)
	q2 = float(q2)
	# create variables in local scope (r is const)
	x = r.x
	y = r.y
	z = r.z

	q = q1 * q2
	# protect from divide by 0 and floating point errors?
	if r.x == 0: x = 0.01
	if r.y == 0: y = 0.01
	if r.z == 0: z = 0.01
	# calculate magnitude of distance
	rAbsolute = sqrt(r[0]*r[0]+r[1]*r[1]+r[2]*r[2])
	# calculate overall force
	if rAbsolute > 0: fAbs = q/(rAbsolute*rAbsolute)
	else: fAbs = 100000000
	return fAbs
	# calculate the coulomb force between the objects, split into component vectors
	#return LVecBase3f((q1*q2)/(x*x),(q1*q2)/(y*y),(q1*q2)/(z*z))
	#return float(q)/r*r

class WaveSim(ShowBase):
	def __init__(self):
		ShowBase.__init__(self)

		self.scale = 25

		self.set_background_color(0.,0.,0.,1.)

		self.cam.setPos(self.scale/2,-60,self.scale/2)

		# create vector field as 2d numpy array
		#field = np.array([np.arange(scale) for _ in range(scale)])
		#self.field = np.zeros((self.scale, self.scale))
		#print(field)
		#print(field.shape)

		# generate a vertex format 
		#array = GeomVertexArrayFormat()
		#array.addColumn("vertex", 3, Geom.NTFloat32, Geom.CPoint)
		#vertexFormat = GeomVertexFormat()
		#vertexFormat.addArray(array)
		vertexFormat = GeomVertexFormat.getV3cp() # columns: vertex, colour ('color' packed RGBA style)
		#vertexFormat = GeomVertexFormat.registerFormat(vertexFormat)

		# populate vertex array with rows for each vertex (point in field)
		vdata = GeomVertexData('fieldVertexData', vertexFormat, Geom.UHStatic)
		vdata.setNumRows(self.scale*self.scale*self.scale)

		# fill array with default data
		vertex = GeomVertexWriter(vdata, 'vertex')
		color = GeomVertexWriter(vdata, 'color')
		for j in range(self.scale):
			for i in range(self.scale*self.scale):
				vertex.addData3(float(i%self.scale),float(j%self.scale),float(i/self.scale))
				color.addData4(1.,1.,1.,1.)

		pointsPrim = GeomPoints(Geom.UHStatic)
		pointsPrim.addConsecutiveVertices(0, self.scale*self.scale*self.scale)

		points = Geom(vdata)
		points.addPrimitive(pointsPrim)
		pointsPrim.closePrimitive()
		#self.cam.setRenderModePerspective()

		# create geometry node for field
		fieldGeomNode = GeomNode('field')
		fieldGeomNode.addGeom(points)
		self.fieldGeomNP = render.attachNewNode(fieldGeomNode)
		self.fieldGeomNP.setRenderModeThickness(5.) 

		self.accept("arrow_left", self.move, ["left"])
		self.accept("arrow_right", self.move, ["right"])
		self.accept("arrow_up", self.move, ["up"])
		self.accept("arrow_down", self.move, ["down"])

		#self.cam.lookAt(self.fieldGeomNP)

		self.taskMgr.add(self.update, "update")

	def update(self, task):
		global t
		t += 0.01
		# transform points
		#self.vdata = self.points.getVertexData()
		#print(self.vdata)
		editNode = self.fieldGeomNP.node()
		for i in range(editNode.getNumGeoms()):
			geom = editNode.modifyGeom(i)
			vdata = geom.modifyVertexData()
			vdata.setNumRows(self.scale*self.scale*self.scale)

			col = GeomVertexWriter(vdata, 'color')
			vertexWriter = GeomVertexWriter(vdata, 'vertex')
			vertexReader = GeomVertexReader(vdata, 'vertex')

			#s = prim.getPrimitiveStart(0)
			#e = prim.getPrimitiveEnd(0)

			#for i in range(s, e):
			while not vertexReader.isAtEnd():
				#prim = geom.modifyPrimitive(i).decompose()
				#vertexReader.setRow(prim.getVertex(i))
				v = vertexReader.getData3()
				#assert v.getShape() == 3, f"Vertex row does not return 3d vector!"
				r = v - LVecBase3f(self.scale/2.,self.scale/2.,self.scale/2.)
				coulForce = coul(r,10.,1.)
				vertexWriter.setData3((v[0]+coulForce)%self.scale,(v[1]+coulForce)%self.scale,(v[2]+coulForce)%self.scale)
				col.setData4(coulForce*coulForce*100,v[1]/25,1-(v[1]/25),1.)
				#print("vertex %s: %s" % (i, repr(v)))
				#col.setRow(prim.getVertex(i))
				#col.setData4(sqrt(v[0]*v[0])/50, sqrt(v[1]*v[1])/200, sqrt(v[2]*v[2])/50, 1.)
				#col.setData4(1.,1.,1.,1.)

		return task.cont

	def move(self, direction):
		if direction == "left":
			self.cam.setH(self.cam.getH()+1)
		if direction == "right":
			self.cam.setH(self.cam.getH()-1)
		if direction == "up":
			self.cam.setR(self.cam.getR()+1)
		if direction == "down":
			self.cam.setR(self.cam.getR()-1)

app = WaveSim()

shader = Shader.load(Shader.SL_GLSL,
                     vertex="simplevert.vert",
                     fragment="simplefrag.frag")
render.setShader(shader)

app.run()
