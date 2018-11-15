/*
 * Copyright (c) 2017, AlbertuSoft <adeptalbert@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Extras 2.0

Entity {
	id: entity

	property real axisLength: 1.0
	property real axisWidth: 0.02
	property real alpha: 0.8

	property color xcolor: "#802020"
	property color ycolor: "#208020"
	property color zcolor: "#202080"

	property int rings: 2
	property int slices: 8

	// ---------- Axis-X ----------

	Entity {
		CylinderMesh {
			id: axisXmesh
			length: 2*entity.axisLength
			radius: entity.axisWidth
			rings: entity.rings
			slices: entity.slices
		}
		Transform {
			id: axisXTransform
			rotation: fromEulerAngles( 0, 0, 90.0 )
		}
		EmittingMaterial {
			id: axisXmat
			emit: entity.xcolor
			alpha: entity.alpha
		}
		components: [ axisXmesh, axisXTransform, axisXmat ]
	}

	Entity {
		ConeMesh {
			id: arrowXmesh
			bottomRadius: entity.axisWidth * 10
			topRadius: 0.0
			length: entity.axisWidth * 30
			rings: entity.rings
			slices: entity.slices
		}
		Transform {
			id: arrowXtrans
			translation: Qt.vector3d( entity.axisLength, 0, 0 )
			rotation: fromEulerAngles( 0.0, 0.0, -90.0 )
		}
		EmittingMaterial {
			id: arrowXmat
			emit: entity.xcolor
			alpha: entity.alpha
		}
		components: [ arrowXmesh, arrowXtrans, arrowXmat ]
	}

	// ---------- Axis-Y ----------

	Entity {
		CylinderMesh {
			id: axisYmesh
			length: 2*entity.axisLength
			radius: entity.axisWidth
			rings: entity.rings
			slices: entity.slices
		}
		Transform {
			id: axisYTransform
			rotation: fromEulerAngles( 0, 0, 0.0 )
		}
		EmittingMaterial {
			id: axisYmat
			emit: entity.ycolor
			alpha: entity.alpha
		}
		components: [ axisYmesh, axisYTransform, axisYmat ]
	}

	Entity {
		ConeMesh {
			id: arrowYmesh
			bottomRadius: entity.axisWidth * 10
			topRadius: 0.0
			length: entity.axisWidth * 30
			rings: entity.rings
			slices: entity.slices
		}
		Transform {
			id: arrowYtrans
			translation: Qt.vector3d( 0, entity.axisLength, 0 )
			rotation: fromEulerAngles( 0.0, 0.0, 0.0 )
		}
		EmittingMaterial {
			id: arrowYmat
			emit: entity.ycolor
			alpha: entity.alpha
		}
		components: [ arrowYmesh, arrowYtrans, arrowYmat ]
	}

	// ---------- Axis-Z ----------

	Entity {
		CylinderMesh {
			id: axisZmesh
			length: 2*entity.axisLength
			radius: entity.axisWidth
			rings: entity.rings
			slices: entity.slices
		}
		Transform {
			id: axisZTransform
			rotation: fromEulerAngles( 90.0, 0, 0.0 )
		}
		EmittingMaterial {
			id: axisZmat
			emit: entity.zcolor
			alpha: entity.alpha
		}
		components: [ axisZmesh, axisZTransform, axisZmat ]
	}

	Entity {
		ConeMesh {
			id: arrowZmesh
			bottomRadius: entity.axisWidth * 10
			topRadius: 0.0
			length: entity.axisWidth * 30
			rings: entity.rings
			slices: entity.slices
		}
		Transform {
			id: arrowZtrans
			translation: Qt.vector3d( 0, 0, entity.axisLength )
			rotation: fromEulerAngles( 90.0, 0.0, 0.0 )
		}
		EmittingMaterial {
			id: arrowZmat
			emit: entity.zcolor
			alpha: entity.alpha
		}
		components: [ arrowZmesh, arrowZtrans, arrowZmat ]
	}

}
