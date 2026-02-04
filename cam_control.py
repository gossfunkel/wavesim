# UTILITY FUNCTIONS FOR USE WITH PANDA3D

def move_cam(direction):
    pos = base.cam.get_pos()
    match direction:
        case "left":
            base.cam.setPos(pos.x - .2, pos.y, pos.z)
        case "right":
            base.cam.setPos(pos.x + .2, pos.y, pos.z)
        case "fwd":
            base.cam.setPos(pos.x, pos.y + .2, pos.z)
        case "back":
            base.cam.setPos(pos.x, pos.y - .2, pos.z)
        case _: 
            print("Move direction not recognised!")
    
def enable_camera_controls():
    base.accept("arrow_left", move_cam, ["left"])
    base.accept("arrow_left-repeat", move_cam, ["left"])
    base.accept("a", move_cam, ["left"])
    base.accept("a-repeat", move_cam, ["left"])
    base.accept("arrow_right", move_cam, ["right"])
    base.accept("arrow_right-repeat", move_cam, ["right"])
    base.accept("d", move_cam, ["right"])
    base.accept("d-repeat", move_cam, ["right"])
    base.accept("arrow_up", move_cam, ["fwd"])
    base.accept("arrow_up-repeat", move_cam, ["fwd"])
    base.accept("w", move_cam, ["fwd"])
    base.accept("w-repeat", move_cam, ["fwd"])
    base.accept("arrow_down", move_cam, ["back"])
    base.accept("arrow_down-repeat", move_cam, ["back"])
    base.accept("s", move_cam, ["back"])
    base.accept("s-repeat", move_cam, ["back"])