from direct.showbase.ShowBase import ShowBase
from panda3d.core import Shader, ShaderInput, ShaderBuffer, ComputeNode, loadPrcFileData
from panda3d.core import Geom, GeomNode, GeomEnums, GeomTriangles, GeomVertexArrayFormat, GeomVertexFormat, GeomVertexData
from panda3d.core import TextureStage, TexGenAttrib, TransparencyAttrib, LVecBase3f, BoundingBox, BoundingVolume
from math import sin, cos
from array import array
import numpy as np
#import type

config_vars = """
win-size 1920 1000
hardware-animated-vertices 1
gl-version 3 2
sync-video 0
want-pstats 1
pstats-gpu-timing 1
pstats-tasks 1 
gl-debug 1
show-frame-rate-meter 1
"""
loadPrcFileData("", config_vars)

sys_scale = 50.0
triSize = 8.0
#spriteNum = 25

col = {
	"white": 		  (1.,1.,1., 1.),
	"electron_aqua":  (0.,1.,1., 1.),
	"hydrogen_blue":  (0.,0.,1., 1.),
	"carbon_yellow":  (1.,1.,0., 1.),
	"nitrogen_green": (0.,1.,0., 1.),
	"oxygen_red": 	  (1.,0.,0., 1.),
	"fluorine_green": (0.,1.,.5, 1.)
}

class Element():
	def __init__(self, name, atomicNum, atomicWeight):
		assert typeof(name) == str, f'non-string variable passed to Element constructor for variable \'name\': requires str type'
		assert typeof(atomicNum) == int, f'non-integer variable passed to Element constructor for variable \'atomicNum\': requires int type'
		assert typeof(atomicWeight) == float, f'non-float variable passed to Element constructor for variable \'atomicWeight\': requires float type'
		self.name = name
		self.atomicNum = atomicNum
		self.atomicWeight = atomicWeight
		self.size = 3. * atomicWeight / 40.


# scale has a maximum value of 3.5- effective minimum is around 1
sprites = []

class WaveSim(ShowBase):
	def __init__(self):
		ShowBase.__init__(self)

		#global sys_scale
		self.globalScale = int(sys_scale)
		#print(self.globalScale)
		self.scale3d = int(self.globalScale*self.globalScale*self.globalScale)

		self.set_background_color(0.5,0.5,0.5,1.)
		self.cam.setPos(5.,-10.,5.)

		# DEFINE GRAPH OF QUADS
		#floats = np.empty(self.scale3d*11, dtype='f')
		floats = []
		for i in range(int(self.globalScale)):
			for j in range(int(self.globalScale)):
				for k in range(int(self.globalScale)):
					#print("i: " + str(i) + ", j: " + str(j) + ", k: " + str(k))
					#floats += 	[float((i+1)/self.globalScale),float((j+1)/self.globalScale),float((k+1)/self.globalScale),
					#			float((i+1)/self.globalScale),float((j+1)/self.globalScale)-1,float((k+1)/self.globalScale),
					#for _ in range(3):
					#floats[i+j+k:i+j+k+11] = [float(i+1),float(j+1),float(k+1), 1.,# pos 		vec4
					floats += [float((i+1)/2),float((j+1)/2),float((k+1)/2), 1.,	# pos 		vec4
								0.,-1.,0, 											# normal	vec3
								float(triSize),										# size 		float
								0.,0.,0.,0.											# col 		vec4
							]
		#print(floats)

		initial_data = array('f', floats)
		buffer = ShaderBuffer('dataPoints', initial_data.tobytes(), GeomEnums.UH_static)
		#buffer = ShaderBuffer('dataPoints', floats.tobytes(), GeomEnums.UH_static)

		vertexFormat = GeomVertexFormat.get_empty()
		# populate vertex array with rows for each vertex (point in field)
		vdata = GeomVertexData('dataPoints', vertexFormat, Geom.UHStatic)
		vdata.setNumRows(self.scale3d * 3) # three vertices per point
		#vdata.setNumRows(spriteNum)

		# create geometry node for field
		fieldGeomNode = GeomNode('fieldNode')
		quads = []

		# This represents a draw call, indicating how many vertices we want to draw.
		triPrims = GeomTriangles(GeomEnums.UH_static)
		triPrims.add_next_vertices(self.scale3d * 3) # three vertices per point
		triPrims.closePrimitive()

		geometry = Geom(vdata)
		geometry.addPrimitive(triPrims)
		# setting a padded bounding volume so that Panda doesn't try to cull it (rdb):
		geometry.set_bounds(BoundingBox((-1, -1, -1), (self.globalScale+1, self.globalScale+1, self.globalScale+1))) 
		
		fieldGeomNode.addGeom(geometry)

		self.shader = Shader.load(Shader.SL_GLSL,
                     vertex="simplevert.vert",
                     fragment="simplefrag.frag")
		self.fieldGeomNP = render.attachNewNode(fieldGeomNode)
		#self.fieldTS = TextureStage('fieldTS')
		self.fieldGeomNP.setShader(self.shader)
		self.fieldGeomNP.setShaderInput(ShaderInput('sys_scale',sys_scale))
		self.fieldGeomNP.setShaderInput("DataPointBuffer", buffer)
		self.fieldGeomNP.set_two_sided(True)
		#self.fieldGeomNP.set_depth_write(False)
		self.fieldGeomNP.node().set_bounds_type(BoundingVolume.BT_box)
		#self.fieldGeomNP.show_bounds()

		self.fieldGeomNP.setTransparency(TransparencyAttrib.MDual)

		# Compute node
		self.computeNode = ComputeNode("waveSim")
		self.computeNode.add_dispatch(self.scale3d // 16, 1, 1)
		self.computeNP = render.attachNewNode(self.computeNode)
		self.computeNP.set_shader(Shader.load_compute(Shader.SL_GLSL, "waveSim.comp"))
		self.computeNP.set_shader_input("sys_scale", self.scale3d)
		self.computeNP.set_shader_input("DataPointBuffer", buffer)
		#self.computeNP.set_shader_input("n", self.qn_n)
		#self.computeNP.set_shader_input("l", self.qn_l)
		#self.computeNP.set_shader_input("ml", self.qn_ml)
		#self.computeNP.set_shader_input("ms", self.qn_s)

		self.accept("arrow_left", self.move, ["left"])
		self.accept("arrow_right", self.move, ["right"])
		self.accept("arrow_up", self.move, ["up"])
		self.accept("arrow_down", self.move, ["down"])

		self.t = 0.0

		#self.cam.lookAt(self.fieldGeomNP)

		self.taskMgr.add(self.update, "update")

	def update(self, task):
		self.t += 0.001

		self.cam.setPos(self.globalScale/2. + 80. * -sin(self.t*1.),self.globalScale/2. + 80. * cos(self.t*1.),self.globalScale/4. - 5. * sin(self.t))
		self.cam.lookAt(self.globalScale/4.,self.globalScale/4.,self.globalScale/4.)

		return task.cont

	def move(self, direction):
		if direction == "left":
			self.cam.setH(self.cam.getH()+1)
		if direction == "right":
			self.cam.setH(self.cam.getH()-1)
		if direction == "up":
			#self.cam.setP(self.cam.getP()+1)
			self.cam.setY(self.cam.getY()+1.)
		if direction == "down":
			#self.cam.setP(self.cam.getP()-1)
			self.cam.setY(self.cam.getY()-1.)

app = WaveSim()

app.run()
