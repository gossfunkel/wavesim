from direct.showbase.ShowBase import ShowBase
from panda3d.core import Shader, loadPrcFileData, GeomVertexArrayFormat, GeomVertexFormat, GeomVertexData
from panda3d.core import GeomVertexWriter, Geom, GeomNode, GeomPoints, GeomVertexReader, LVecBase3f
from panda3d.core import TextureStage, ShaderInput, TexGenAttrib, TransparencyAttrib
from math import floor, sin, cos, sqrt
import numpy as np

config_vars = """
win-size 1920 1000
show-frame-rate-meter 1
hardware-animated-vertices true
threading-model Cull/Draw
"""
loadPrcFileData("", config_vars)

sys_scale = 20
spriteNum = 3

class WaveSim(ShowBase):
	def __init__(self):
		ShowBase.__init__(self)
		global sys_scale
		self.scale = sys_scale
		self.scale3d = self.scale*self.scale*self.scale

		self.set_background_color(.8,.8,.8,1.)

		self.cam.setPos(15.,-75.,11.)

		# custom geom format
		vaf = GeomVertexArrayFormat()
		vaf.addColumn("vertex", 3, Geom.NTFloat32, Geom.CPoint)
		vaf.addColumn("color", 4, Geom.NTFloat32, Geom.CPoint)
		vaf.addColumn("scale", 1, Geom.NTFloat32, Geom.CPoint)
		#vaf.addColumn("charge", 1, Geom.NTFloat32, Geom.CPoint)
		#vaf.addColumn("spinVector", 4, Geom.NTFloat32, Geom.CPoint)
		#vertexFormat = GeomVertexFormat.getV3cp() # columns: vertex, colour ('color' packed RGBA style)
		vertexFormat = GeomVertexFormat()
		vertexFormat.addArray(vaf)
		vertexFormat = GeomVertexFormat.registerFormat(vertexFormat)

		# populate vertex array with rows for each vertex (point in field)
		vdata = GeomVertexData('fieldVertexData', vertexFormat, Geom.UHStatic)
		#vdata.setNumRows(self.scale3d)
		vdata.setNumRows(spriteNum)

		# fill array with default data
		vertex = GeomVertexWriter(vdata, 'vertex')
		color = GeomVertexWriter(vdata, 'color')
		scale = GeomVertexWriter(vdata, 'scale')
		#for j in range(self.scale):
		#	for i in range(self.scale*self.scale):
		vertex.addData3(0.,0.,0.)
		color.addData4(1.,1.,0.,1.)
		scale.addData1(1.)
		vertex.addData3(30.,0.,0.)
		color.addData4(0.,1.,1.,1.)
		scale.addData1(1.5)
		vertex.addData3(15.,0.,22.)
		color.addData4(0.,1.,0.,1.)
		scale.addData1(2.)

		pointsPrim = GeomPoints(Geom.UHStatic)
		pointsPrim.addConsecutiveVertices(0, spriteNum)

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
		self.fieldGeomNP.setRenderModePerspective(1)
		self.fieldGeomNP.setRenderModeThickness(10.)
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
		self.t += 0.01
		#self.cam.setPos(self.scale/2. + 50. * -sin(self.t*1.),self.scale/2. + 50. * cos(self.t*1.),self.scale*sin(self.t))
		#self.cam.lookAt(self.scale/2.,self.scale/2.,self.scale/2.)

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
