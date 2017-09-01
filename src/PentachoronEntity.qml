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

	property matrix4x4 rotationMatrix // it is an identiry matrix at initialization	

	// define pentachoron coords
	property variant basePoints: [
		Qt.vector4d(  0.000,  1.000, -0.500, -0.500 ),
		Qt.vector4d( -0.866, -0.500, -0.500, -0.500 ),
		Qt.vector4d(  0.866, -0.500, -0.500, -0.500 ),
		Qt.vector4d(  0.000,  0.000,  0.866, -0.500 ),
		Qt.vector4d(  0.000,  0.000,  0.000,  0.866 )
	]
	
	property variant offset: Qt.vector4d( 0.0, 0.0, 0.0, 0.0 )
	property real scale: 1.0
	property color edgeColor: "#A0A0A0"

	property variant points: [
		rotationMatrix.times( basePoints[0].plus(offset) ).times(scale),
		rotationMatrix.times( basePoints[1].plus(offset) ).times(scale),
		rotationMatrix.times( basePoints[2].plus(offset) ).times(scale),
		rotationMatrix.times( basePoints[3].plus(offset) ).times(scale),
		rotationMatrix.times( basePoints[4].plus(offset) ).times(scale)
	]

	SphereEntity {
		id: greenBall
		diffuseColor: "#00A000"
		location: entity.points[0].toVector3d()
	}
	SphereEntity {
		id: yellowBall
		diffuseColor: "#A0A000"
		location: entity.points[1].toVector3d()
	}
	SphereEntity {
		id: orangeBall
		diffuseColor: "#F07000"
		location: entity.points[2].toVector3d()
	}
	SphereEntity {
		id: redBall
		diffuseColor: "#A00000"
		location: entity.points[3].toVector3d()
	}
	SphereEntity {
		id: purpleBall
		diffuseColor: "#A000A0"
		location: entity.points[4].toVector3d()
	}
	CylinderEntity {
		diffuseColor: "#A0A0A0"
		startPoint: purpleBall.location
		endPoint: greenBall.location
	}
	CylinderEntity {
		diffuseColor: "#A0A0A0"
		startPoint: purpleBall.location
		endPoint: yellowBall.location
	}
	CylinderEntity {
		diffuseColor: "#A0A0A0"
		startPoint: purpleBall.location
		endPoint: orangeBall.location
	}
	CylinderEntity {
		diffuseColor: "#A0A0A0"
		startPoint: purpleBall.location
		endPoint: redBall.location
	}
	CylinderEntity {
		diffuseColor: entity.edgeColor
		startPoint: greenBall.location
		endPoint: yellowBall.location
	}
	CylinderEntity {
		diffuseColor: entity.edgeColor
		startPoint: yellowBall.location
		endPoint: orangeBall.location
	}
	CylinderEntity {
		diffuseColor: entity.edgeColor
		startPoint: orangeBall.location
		endPoint: greenBall.location
	}
	CylinderEntity {
		diffuseColor: entity.edgeColor
		startPoint: redBall.location
		endPoint: greenBall.location
	}
	CylinderEntity {
		diffuseColor: entity.edgeColor
		startPoint: redBall.location
		endPoint: yellowBall.location
	}
	CylinderEntity {
		diffuseColor: entity.edgeColor
		startPoint: redBall.location
		endPoint: orangeBall.location
	}

}
