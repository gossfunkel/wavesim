from direct.showbase.ShowBase import ShowBase
from panda3d.core import Shader, loadPrcFileData, GeomVertexArrayFormat, GeomVertexFormat, GeomVertexData
from panda3d.core import GeomVertexWriter, Geom, GeomNode, GeomPoints, GeomVertexReader, LVecBase3f
from panda3d.core import TextureStage, ShaderInput, TexGenAttrib
from math import floor, sin, cos, sqrt
import numpy as np

config_vars = """
win-size 1920 1000
show-frame-rate-meter 1
hardware-animated-vertices true
threading-model Cull/Draw
"""
loadPrcFileData("", config_vars)

sys_scale = 25

class WaveSim(ShowBase):
	def __init__(self):
		ShowBase.__init__(self)
		global sys_scale
		self.scale = sys_scale
		self.scale3d = self.scale*self.scale*self.scale

		self.set_background_color(0.,0.,0.,1.)

		self.cam.setPos(self.scale/2,-60,self.scale/2)

		vertexFormat = GeomVertexFormat.getV3cp() # columns: vertex, colour ('color' packed RGBA style)

		# populate vertex array with rows for each vertex (point in field)
		vdata = GeomVertexData('fieldVertexData', vertexFormat, Geom.UHStatic)
		vdata.setNumRows(self.scale3d)

		# fill array with default data
		vertex = GeomVertexWriter(vdata, 'vertex')
		color = GeomVertexWriter(vdata, 'color')
		for j in range(self.scale):
			for i in range(self.scale*self.scale):
				vertex.addData3(float(2*i%self.scale),float(2*j%self.scale),float(i/self.scale))
				color.addData4(1.,1.,1.,0.)

		pointsPrim = GeomPoints(Geom.UHStatic)
		pointsPrim.addConsecutiveVertices(0, self.scale3d)

		points = Geom(vdata)
		points.addPrimitive(pointsPrim)
		pointsPrim.closePrimitive()

		# create geometry node for field
		fieldGeomNode = GeomNode('field')
		fieldGeomNode.addGeom(points)
		self.fieldGeomNP = render.attachNewNode(fieldGeomNode)
		self.fieldGeomNP.setRenderModeThickness(50.) 
		#self.fieldGeomNP.setRenderModePerspective(1)
		#self.fieldGeomNP.set_tex_gen(TextureStage.getDefault(), TexGenAttrib.M_point_sprite)
		self.fieldTS = TextureStage('fieldTS')
		#self.fieldTS.setMode(M_dualTransparency)
		self.fieldGeomNP.setTexScale(self.fieldTS, 5)

		self.accept("arrow_left", self.move, ["left"])
		self.accept("arrow_right", self.move, ["right"])
		self.accept("arrow_up", self.move, ["up"])
		self.accept("arrow_down", self.move, ["down"])

		self.t = 0.0

		self.taskMgr.add(self.update, "update")

	def update(self, task):
		self.t += 0.01
		self.cam.setR(sin(self.t)*10.)

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
#shader.setShaderInput(sys_scale)
render.setShader(shader)
render.setShaderInput(ShaderInput('sys_scale',sys_scale))

app.run()
