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

	property color diffuseColor: "#808080"
	property vector3d startPoint: Qt.vector3d( 0, 0, 0 )
	property vector3d endPoint: Qt.vector3d( 0, 1, 0 )
	property vector3d direction: endPoint.minus(startPoint).normalized()
	property real radius: 0.04
	property bool ambientMaterialFlag: false

	property int rings: 2
	property int slices: 8

	CylinderMesh {
		id: cylinderMesh
		length: endPoint.minus(startPoint).length()
		radius: entity.radius
		rings: entity.rings
		slices: entity.slices
	}

	Transform {
		id: cylinderTransform
		translation: startPoint.plus(endPoint).times(0.5)
		rotation: fromEulerAngles(
			90.0 + Math.asin( -entity.direction.y ) * 180 / Math.PI, // pitch (around X-axis)
			Math.atan2( entity.direction.x, entity.direction.z ) * 180 / Math.PI,// yaw (around Y-axis)
			0.0 // roll (around Z-axis)
		)
	}

	PhongMaterial {
		id: cylinderMaterial
		diffuse: entity.diffuseColor // self-color
		specular: Qt.lighter( diffuse, 2.1 )
		shininess: 3.0
	}

	PhongMaterial {
		id: cylinderMaterial2
		ambient: entity.diffuseColor
		diffuse: "#000000"
		specular: "#000000"
		shininess: 0.0
	}

	components: [ cylinderMesh, cylinderTransform, (ambientMaterialFlag ? cylinderMaterial2 : cylinderMaterial) ]
}
