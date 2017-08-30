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
import QtQuick.Controls 2.2
import QtQuick.Scene3D 2.0
import QtQuick.Layouts 1.3

import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Extras 2.0


Rectangle {
	id: mainScreen
	color: "#002040"

	property real side: (width < height) ? width : height
	property real gap: side * 0.01

	property matrix4x4 rotationMatrix // it is an identiry matrix at initialization

	function constructRotatinMatrix( angle1, angle2, plane, doubleFlag, isoclinicFlag ) {

		function idx(row,column) {
			return (row-1) * 4 + (column-1)
		}

		function makeCosineMat( alpha, plane, invFlag ) {

			var data = new Array(16);
			var axes = [ false, false, false, false ]

			for ( var i=0; i<16; ++i ) data[i] = Math.sin(alpha)
			data[idx(1,1)] = data[idx(2,2)] = data[idx(3,3)] = data[idx(4,4)] = Math.cos(alpha)
			data[idx(1,2)] *= -1.0; data[idx(1,4)] *= -1.0; data[idx(2,3)] *= -1.0; data[idx(3,1)] *= -1.0; data[idx(3,4)] *= -1.0; data[idx(4,2)] *= -1.0

			for ( var j=0; j<plane.length; ++j ) {
				var ch = plane.charAt(j)
				if ( ch == 'x' ) { axes[0] = true }
				if ( ch == 'y' ) { axes[1] = true }
				if ( ch == 'z' ) { axes[2] = true }
				if ( ch == 'w' ) { axes[3] = true }
			}

			if ( invFlag ) {
				for ( var i=0; i<axes.length; ++i ) {
					axes[i] = !axes[i]
				}
			}

			for ( var j=1; j<=axes.length; ++j ) {
				if ( axes[j-1] ) {
					for ( var i=0; i<4; ++i ) {
						data[idx(j,i)] = NaN // will be 0.0 after we call replacenums()
						data[idx(i,j)] = NaN // will be 0.0 after we call replacenums()
					}
					data[idx(j,j)] = 1/0 // will be 1.0 after we call replacenums()
				}
			}

			return data;
		}

		function mergedata( data1, data2 ) {
			var newdata = new Array(data1.length);
			for ( var i=0; i<newdata.length; ++i ) {
				if ( (!isNaN(data1[i])) && (data1[i] != 1/0) ) { newdata[i] = data1[i] }
				if ( (!isNaN(data2[i])) && (data2[i] != 1/0) ) { newdata[i] = data2[i] }
			}
			return newdata
		}

		function replacenums( data ) {
			for ( var i=0; i<data.length; ++i ) {
				if ( isNaN(data[i]) ) { data[i] = 0.0 }
				if ( data[i] == 1/0 ) { data[i] = 1.0 }
			}
			return data
		}

		if ( doubleFlag && isoclinicFlag ) {
			var data1 = makeCosineMat( angle1 * Math.PI / 180, plane, false )
			var data2 = makeCosineMat( angle1 * Math.PI / 180, plane, true )
			return Qt.matrix4x4( replacenums( mergedata( data1, data2 ) ) )
		} else if ( doubleFlag ) {
			var data1 = makeCosineMat( angle1 * Math.PI / 180, plane, false )
			var data2 = makeCosineMat( angle2 * Math.PI / 180, plane, true )
			return Qt.matrix4x4( replacenums( mergedata( data1, data2 ) ) )
		} else {
			return Qt.matrix4x4( replacenums( makeCosineMat( angle1 * Math.PI / 180, plane, false ) ) )
		}
	}

	function updateRotationMatrix() {
		mainScreen.rotationMatrix = constructRotatinMatrix(
			dialItem1.value,
			dialItem2.value,
			planeSelectorCombo.currentText,
			doublerotCheckBox.checkState==Qt.Checked,
			isoclinicrotCheckBox.checkState==Qt.Checked
		)
	}

	FullDial {
		id: dialItem1
		x: mainScreen.width * 0.5 - mainScreen.gap - width
		y: controls.y + controls.height + mainScreen.gap
		width: side - 2*gap
		height: side - 2*gap
		color: "#203020"
		property real side: (mainScreen.height-y < mainScreen.width*0.5) ? mainScreen.height-y : mainScreen.width*0.5
		property real anumatedValue: 0.0
		property real animatedOffset: 0.0
		onValueChanged: {
			updateRotationMatrix()
			animatedOffset = value - anumatedValue
		}
		onAnumatedValueChanged: {
			value = anumatedValue + animatedOffset
		}
	}

	FullDial {
		id: dialItem2
		x: mainScreen.width * 0.5 + mainScreen.gap
		y: controls.y + controls.height + mainScreen.gap
		width: side - 2*gap
		height: side - 2*gap
		color: "#203020"
		enabled: (doublerotCheckBox.checkState == Qt.Checked) && (isoclinicrotCheckBox.checkState == Qt.Unchecked)
		property real side: (mainScreen.height-y < mainScreen.width*0.5) ? mainScreen.height-y : mainScreen.width*0.5
		onValueChanged: {
			updateRotationMatrix()
		}
	}

	Rectangle {
		id: controls
		x: gap
		y: gap + scene.height + gap
		width: mainScreen.width-2*gap
		height: mainScreen.height*0.1
		color: Qt.lighter( mainScreen.color, 1.2 )

		property real w: width / 4

		StyledComboBox {
			id: planeSelectorCombo
			x: gap
			y: gap
			width: parent.w - gap
			height: parent.height - gap*2
			model: [ "xw", "yw", "zw", "xz", "yz", "xy" ]
			currentIndex: 5
			onCurrentTextChanged: {
				updateRotationMatrix()
			}
			styleColor: Qt.lighter( mainScreen.color, 1.4 )
		}

		StyledCheckBox {
			id: animateCheckBox
			x: gap + 1*parent.w
			y: gap
			width: parent.w - gap
			height: parent.height - gap*2
			text: qsTr("Animate")
			checkState: Qt.Unchecked
			onCheckStateChanged: {
				updateRotationMatrix()
			}
		}

		StyledCheckBox{
			id: doublerotCheckBox
			x: gap + 2*parent.w
			y: gap
			width: parent.w - gap
			height: parent.height - gap*2
			text: qsTr("Double")
			checkState: Qt.Checked
			onCheckStateChanged: {
				updateRotationMatrix()
			}
		}

		StyledCheckBox {
			id: isoclinicrotCheckBox
			x: gap + 3*parent.w
			y: gap
			width: parent.w - gap
			height: parent.height - gap*2
			text: qsTr("Isoclinic")
			checkState: Qt.Checked
			enabled: doublerotCheckBox.checkState == Qt.Checked ? true : false
			onCheckStateChanged: {
				updateRotationMatrix()
			}
		}
	}

	Rectangle {
		id: scene
		x: gap
		y: gap
		width: mainScreen.width - 2*gap
		height: mainScreen.height*0.6 - gap
		color: "#303030"
		radius: mainScreen.side * 0.05
		border.width: mainScreen.side * 0.005
		border.color: "#303050"

		property real guiRotationX: 0.0
		property real guiRotationY: 0.0
		property real guiRotationZ: 0.0

		transform: Rotation {
			id: sceneRotation
			axis.x: 1
			axis.y: 0
			axis.z: 0
			origin.x: scene.width / 2
			origin.y: scene.height / 2
		}

		Scene3D {
			id: scene3d
			anchors.fill: parent
			anchors.margins: 10
			focus: true
			aspects: ["input", "logic"]
			cameraAspectRatioMode: Scene3D.AutomaticAspectRatio

			Entity {
				id: sceneRoot

				// ----- Camera -----
				Camera {
					id: camera
					projectionType: CameraLens.PerspectiveProjection
					fieldOfView: 60
					nearPlane : 0.1
					farPlane : 100.0
					position: Qt.vector3d( 0.0, -3.0, 0.0 )
					upVector: Qt.vector3d( 0.0, 0.0, 1.0 )
					viewCenter: Qt.vector3d( 0.0, 0.0, 0.0 )
				}

				// ----- PointLight at camera position -----
				Entity {
					components: [
						PointLight {
							constantAttenuation : 0.0
							linearAttenuation : 0.0
							quadraticAttenuation : 0.0025
						},
						Transform {
							translation: camera.position
						}
					]
				}

				// ----- Pentachoron 3D projection -----
				Entity {
					id: pentachoron3d

					// define pentachoron coords
					property variant basePoints: [
						Qt.vector4d(  0.000,  1.000, -0.500, -0.500 ),
						Qt.vector4d( -0.866, -0.500, -0.500, -0.500 ),
						Qt.vector4d(  0.866, -0.500, -0.500, -0.500 ),
						Qt.vector4d(  0.000,  0.000,  0.866, -0.500 ),
						Qt.vector4d(  0.000,  0.000,  0.000,  0.866 )
					]
					property variant points: [
						mainScreen.rotationMatrix.times( basePoints[0].plus(offset) ),
						mainScreen.rotationMatrix.times( basePoints[1].plus(offset) ),
						mainScreen.rotationMatrix.times( basePoints[2].plus(offset) ),
						mainScreen.rotationMatrix.times( basePoints[3].plus(offset) ),
						mainScreen.rotationMatrix.times( basePoints[4].plus(offset) )
					]
					property variant offset: Qt.vector4d( 0.0, 0.0, 0.0, 0.0 )
					property real scale: 1.0
					property color edgeColor: "#A0A0A0"

					SphereEntity {
						id: greenBall
						diffuseColor: "#00A000"
						location: parent.points[0].toVector3d().times(parent.scale)
					}
					SphereEntity {
						id: yellowBall
						diffuseColor: "#A0A000"
						location: parent.points[1].toVector3d().times(parent.scale)
					}
					SphereEntity {
						id: orangeBall
						diffuseColor: "#F07000"
						location: parent.points[2].toVector3d().times(parent.scale)
					}
					SphereEntity {
						id: redBall
						diffuseColor: "#A00000"
						location: parent.points[3].toVector3d().times(parent.scale)
					}
					SphereEntity {
						id: purpleBall
						diffuseColor: "#A000A0"
						location: parent.points[4].toVector3d().times(parent.scale)
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
						diffuseColor: parent.edgeColor
						startPoint: greenBall.location
						endPoint: yellowBall.location
					}
					CylinderEntity {
						diffuseColor: parent.edgeColor
						startPoint: yellowBall.location
						endPoint: orangeBall.location
					}
					CylinderEntity {
						diffuseColor: parent.edgeColor
						startPoint: orangeBall.location
						endPoint: greenBall.location
					}
					CylinderEntity {
						diffuseColor: parent.edgeColor
						startPoint: redBall.location
						endPoint: greenBall.location
					}
					CylinderEntity {
						diffuseColor: parent.edgeColor
						startPoint: redBall.location
						endPoint: yellowBall.location
					}
					CylinderEntity {
						diffuseColor: parent.edgeColor
						startPoint: redBall.location
						endPoint: orangeBall.location
					}

					CoordinateSystem {
						axisLength: 1.5 * parent.scale
						axisWidth: 0.005 * parent.scale
					}

					Transform {
						id: pentachoron3dTransform
						matrix: {
							var m = Qt.matrix4x4();
							m.rotate(scene.guiRotationZ, Qt.vector3d(0, 0, 1))
							m.rotate(scene.guiRotationX, Qt.vector3d(1, 0, 0))
							m.rotate(scene.guiRotationY, Qt.vector3d(0, 1, 0))
							m.translate(Qt.vector3d(0, 0, 0));
							return m;
						}
					}
					components: [ pentachoron3dTransform ]
				}

				components: [
					RenderSettings {
						activeFrameGraph: ForwardRenderer {
							camera: camera
							clearColor: "transparent"
						}
					},
					InputSettings { }
				]

			} // Scene3D.Entity
		} // Scene3D

		MouseArea {
			anchors.fill: parent
			onPressed: {
				mousePressX = mouseX / width
				mousePressY = mouseY / height
				angleXatPress = scene.guiRotationX
				angleYatPress = scene.guiRotationY
				angleZatPress = scene.guiRotationZ
			}
			onPositionChanged: {
				scene.guiRotationZ = angleZatPress + ( mouse.x / width - mousePressX ) * 120.0
				scene.guiRotationX = angleXatPress + ( mouse.y / height - mousePressY ) * 120.0 * Math.cos( scene.guiRotationZ*Math.PI/180 )
				scene.guiRotationY = angleXatPress + ( mouse.y / height - mousePressY ) * 120.0 * Math.sin( -scene.guiRotationZ*Math.PI/180 )
			}
			onDoubleClicked: {
				scene.guiRotationX = 0.0
				scene.guiRotationY = 0.0
				scene.guiRotationZ = 0.0
				angleXatPress = 0.0
				angleYatPress = 0.0
				angleZatPress = 0.0
			}
			property real mousePressX: 0.0
			property real mousePressY: 0.0
			property real angleXatPress: 0.0
			property real angleYatPress: 0.0
			property real angleZatPress: 0.0
		}

	} // Rectangle of Scene3D

	// Help Button
	Rectangle {
		x: mainScreen.width - 2*gap - width
		y: 2*gap
		width: mainScreen.width / 9
		height: width
		z: 2
		radius: width
		color: "#604020"

		Text {
			anchors.fill: parent
			color: "#FFFFFF"
			font.bold: true
			font.pixelSize: parent.height / 1.5
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			text: "?"
		}

		MouseArea {
			anchors.fill: parent
			onClicked: {
				page.state = "HELP"
			}
		}
	}

	NumberAnimation {
		id: animator
		target: dialItem1
		property: "anumatedValue"
		duration: 10000
		from: 0
		to: 360
		loops: Animation.Infinite
		running: true
		paused: animateCheckBox.checkState == Qt.Unchecked
	}

	/*------------------------------------------------------------------*+
	|                         KEYBOARD HANDLERS                          |
	+*------------------------------------------------------------------*/

	Keys.onReleased: {
		page.handleBackKeyEvent( event, "" )
	}

}
