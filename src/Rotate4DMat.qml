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

import QtQuick 2.7

Item {

	property variant angles: [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]

	// ---------- XY ----------
	property real angleXY: angles[0] * Math.PI / 180
	property real sinAlphaXY: Math.sin(angleXY)
	property real cosAlphaXY: Math.cos(angleXY)
	property matrix4x4 matXY: Qt.matrix4x4(
			1.0,         0.0,         0.0,         0.0,
			0.0,         1.0,         0.0,         0.0,
			0.0,         0.0,  cosAlphaXY, -sinAlphaXY,
			0.0,         0.0,  sinAlphaXY,  cosAlphaXY
	)

	// ---------- XZ ----------
	property real angleXZ: angles[1] * Math.PI / 180
	property real sinAlphaXZ: Math.sin(angleXZ)
	property real cosAlphaXZ: Math.cos(angleXZ)
	property matrix4x4 matXZ: Qt.matrix4x4(
			1.0,         0.0,         0.0,         0.0,
			0.0,  cosAlphaXZ,         0.0,  sinAlphaXZ,
			0.0,         0.0,         1.0,         0.0,
			0.0, -sinAlphaXZ,         0.0,  cosAlphaXZ
	)

	// ---------- YZ ----------
	property real angleYZ: angles[2] * Math.PI / 180
	property real sinAlphaYZ: Math.sin(angleYZ)
	property real cosAlphaYZ: Math.cos(angleYZ)
	property matrix4x4 matYZ: Qt.matrix4x4(
		 cosAlphaYZ,         0.0,         0.0, -sinAlphaYZ,
			0.0,         1.0,         0.0,         0.0,
			0.0,         0.0,         1.0,         0.0,
		 sinAlphaYZ,         0.0,         0.0,  cosAlphaYZ
	)

	// ---------- XW ----------
	property real angleXW: angles[3] * Math.PI / 180
	property real sinAlphaXW: Math.sin(angleXW)
	property real cosAlphaXW: Math.cos(angleXW)
	property matrix4x4 matXW: Qt.matrix4x4(
			1.0,         0.0,         0.0,         0.0,
			0.0,  cosAlphaXW, -sinAlphaXW,         0.0,
			0.0,  sinAlphaXW,  cosAlphaXW,         0.0,
			0.0,         0.0,         0.0,         1.0
	)

	// ---------- YW ----------
	property real angleYW: angles[4] * Math.PI / 180
	property real sinAlphaYW: Math.sin(angleYW)
	property real cosAlphaYW: Math.cos(angleYW)
	property matrix4x4 matYW: Qt.matrix4x4(
		 cosAlphaYW,         0.0,  sinAlphaYW,         0.0,
			0.0,         1.0,         0.0,         0.0,
		-sinAlphaYW,         0.0,  cosAlphaYW,         0.0,
			0.0,         0.0,         0.0,         1.0
	)

	// ---------- ZW ----------
	property real angleZW: angles[5] * Math.PI / 180
	property real sinAlphaZW: Math.sin(angleZW)
	property real cosAlphaZW: Math.cos(angleZW)
	property matrix4x4 matZW: Qt.matrix4x4(
		 cosAlphaZW, -sinAlphaZW,         0.0,         0.0,
		 sinAlphaZW,  cosAlphaZW,         0.0,         0.0,
			0.0,         0.0,         1.0,         0.0,
			0.0,         0.0,         0.0,         1.0
	)

	property matrix4x4 matR: matXY.times(matXZ).times(matYZ).times(matXW).times(matYW).times(matZW)
}
