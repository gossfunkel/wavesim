from direct.showbase.ShowBase import ShowBase
from panda3d.core import Shader, loadPrcFileData, GeomVertexArrayFormat, GeomVertexFormat, GeomVertexData
from panda3d.core import GeomVertexWriter, Geom, GeomNode, GeomPoints, GeomVertexReader, LVecBase3f
from panda3d.core import TextureStage, ShaderInput, TexGenAttrib, TransparencyAttrib
from math import floor, sin, cos, sqrt
import numpy as np
#import type

config_vars = """
win-size 1920 1000
show-frame-rate-meter 1
hardware-animated-vertices true
threading-model Cull/Draw
sync-video false
"""
loadPrcFileData("", config_vars)

sys_scale = 20
spriteNum = 20

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
		global sys_scale
		self.scale = sys_scale
		self.scale3d = self.scale*self.scale*self.scale

		self.set_background_color(.08,.02,.14,1.)

		self.cam.setPos(15.,-75.,11.)

		# custom geom format
		vaf = GeomVertexArrayFormat()
		vaf.addColumn("vertex", 3, Geom.NTFloat32, Geom.CPoint)
		vaf.addColumn("color", 4, Geom.NTFloat32, Geom.CColor)
		vaf.addColumn("scale", 1, Geom.NTFloat32, Geom.COther)
		#vaf.addColumn("charge", 1, Geom.NTFloat32, Geom.CPoint)
		#vaf.addColumn("spinVector", 4, Geom.NTFloat32, Geom.CPoint)
		#vertexFormat = GeomVertexFormat.getV3cp() # columns: vertex, colour ('color' packed RGBA style)
		vertexFormat = GeomVertexFormat()
		vertexFormat.addArray(vaf)
		vertexFormat = GeomVertexFormat.registerFormat(vertexFormat)

		# populate vertex array with rows for each vertex (point in field)
		vdata = GeomVertexData('fieldVertexData', vertexFormat, Geom.UHStatic)
		vdata.setNumRows(self.scale3d)
		#vdata.setNumRows(spriteNum)

		# fill array with default data
		vertex = GeomVertexWriter(vdata, 'vertex')
		colour = GeomVertexWriter(vdata, 'color')
		scale = GeomVertexWriter(vdata, 'scale')

		# DEFINE GRAPH OF POINTS
		for j in range(self.scale):
			for i in range(self.scale*self.scale):
				vertex.addData3(float(i%self.scale),float(j%self.scale),float(i/self.scale))
				colour.addData4(0.,0.,0.,0.)
				scale.addData1(.5)

		""" # INDIVIDUALLY DEFINE POINTS
		vertex.addData3(0.,0.,0.)
		color.addData4(col["electron_aqua"])
		scale.addData1(1.)
		vertex.addData3(30.,0.,0.)
		color.addData4(col["carbon_yellow"])
		scale.addData1(2.)
		vertex.addData3(15.,0.,22.)
		color.addData4(col["oxygen_red"])
		scale.addData1(2.2)
		"""

		pointsPrim = GeomPoints(Geom.UHStatic)
		pointsPrim.addConsecutiveVertices(0, self.scale3d)

		points = Geom(vdata)
		points.addPrimitive(pointsPrim)
		pointsPrim.closePrimitive()

		# create geometry node for field
		fieldGeomNode = GeomNode('field')
		fieldGeomNode.addGeom(points)
		self.fieldGeomNP = render.attachNewNode(fieldGeomNode)
		#self.fieldTS = TextureStage('fieldTS')
		self.fieldGeomNP.setTransparency(TransparencyAttrib.MDual) #thanks @squiggle 
		#self.fieldGeomNP.set_tex_gen(self.fieldTS, TexGenAttrib.M_point_sprite)
		self.fieldGeomNP.set_tex_gen(TextureStage.getDefault(), TexGenAttrib.M_point_sprite)
		#self.fieldGeomNP.setRenderModePerspective(1)
		self.fieldGeomNP.setRenderModeThickness(50.)
		#self.fieldGeomNP.set_tex_scale(self.fieldTS, 2.)
		self.fieldGeomNP.set_tex_scale(TextureStage.getDefault(), 2.)
		#self.fieldGeomNP.set_tex_offset(self.fieldTS,-1.)
		self.fieldGeomNP.set_tex_offset(TextureStage.getDefault(),1.)

		self.accept("arrow_left", self.move, ["left"])
		self.accept("arrow_right", self.move, ["right"])
		self.accept("arrow_up", self.move, ["up"])
		self.accept("arrow_down", self.move, ["down"])

		self.t = 0.0

		#self.cam.lookAt(self.fieldGeomNP)

		self.taskMgr.add(self.update, "update")

	def update(self, task):
		self.t += 0.001

		self.cam.setPos(self.scale/2. + 50. * -sin(self.t*1.),self.scale/2. + 50. * cos(self.t*1.),.5*self.scale*sin(self.t))
		self.cam.lookAt(self.scale/2.,self.scale/2.,self.scale/2.)

		return task.cont

	def move(self, direction):
		if direction == "left":
			self.cam.setH(self.cam.getH()+1)
		if direction == "right":
			self.cam.setH(self.cam.getH()-1)
		if direction == "up":
			self.cam.setP(self.cam.getP()+1)
		if direction == "down":
			self.cam.setP(self.cam.getP()-1)

app = WaveSim()

shader = Shader.load(Shader.SL_GLSL,
                     vertex="simplevert.vert",
                     fragment="simplefrag.frag")
render.setShader(shader)
render.setShaderInput(ShaderInput('sys_scale',sys_scale))

app.run()
