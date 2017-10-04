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

	property variant _PLANES: [ "xy", "xz", "yz", "xw", "yw", "zw" ]

	/*------------------------------------------------------------------*+
	|                                SCENE                               |
	+*------------------------------------------------------------------*/

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

				// ----- Pentachoron 3D projection & Coordinate System -----
				Entity {
					property real scale: 1.0

					PentachoronEntity {
						id: pentachoronEntity
						scale: parent.scale
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

	/*------------------------------------------------------------------*+
	|                               CONTROLS                             |
	+*------------------------------------------------------------------*/

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

	TabBar {
		id: tabBar
		x: mainScreen.gap
		y: scene.y + scene.height + gap
		width: mainScreen.width - 2*mainScreen.gap
		height: mainScreen.height * 0.05

		background: Rectangle {
			color: Qt.lighter( mainScreen.color, 1.2 )
		}

		StyledTabButton {
			text: qsTr("Basic control")
			bgColor: mainScreen.color
			textColor: "#F0F0FF"
		}
		StyledTabButton {
			text: qsTr("Full control")
			bgColor: mainScreen.color
			textColor: "#F0F0FF"
		}
		StyledTabButton {
			text: qsTr("Special control")
			bgColor: mainScreen.color
			textColor: "#F0F0FF"
		}
	}

	StackLayout {

		id: controlLayout
		x: mainScreen.gap
		y: tabBar.y + tabBar.height
		width: tabBar.width
		height: mainScreen.height - y - mainScreen.gap
		currentIndex: tabBar.currentIndex

		// ---------- Basic Control ----------

		Rectangle {
			anchors.fill: parent
			color: Qt.lighter( mainScreen.color, 1.2 )

			Column {
				spacing: mainScreen.gap

				Rectangle {
					width: parent.width
					height: mainScreen.height * 0.06
					color: Qt.lighter( mainScreen.color, 1.2 )

					property real w: width / 4

					StyledComboBox {
						id: planeSelectorCombo
						x: mainScreen.gap
						y: mainScreen.gap
						width: parent.w - gap
						height: parent.height - gap*2
						model: mainScreen._PLANES
						currentIndex: 0
						onCurrentTextChanged: {
							updateRotationMatrix()
						}
						styleColor: Qt.lighter( mainScreen.color, 1.4 )
					}

					StyledCheckBox {
						id: animateCheckBox
						x: mainScreen.gap + 1*parent.w
						y: mainScreen.gap
						width: parent.w - mainScreen.gap
						height: parent.height - mainScreen.gap*2
						text: qsTr("Animate")
						checkState: Qt.Unchecked
						onCheckStateChanged: {
							updateRotationMatrix()
						}
					}

					StyledCheckBox{
						id: doublerotCheckBox
						x: mainScreen.gap + 2*parent.w
						y: mainScreen.gap
						width: parent.w - mainScreen.gap
						height: parent.height - mainScreen.gap*2
						text: qsTr("Double")
						checkState: Qt.Unchecked
						onCheckStateChanged: {
							updateRotationMatrix()
						}
					}

					StyledCheckBox {
						id: isoclinicrotCheckBox
						x: mainScreen.gap + 3*parent.w
						y: mainScreen.gap
						width: parent.w - mainScreen.gap
						height: parent.height - mainScreen.gap*2
						text: qsTr("Isoclinic")
						checkState: Qt.Unchecked
						enabled: doublerotCheckBox.checkState == Qt.Checked ? true : false
						onCheckStateChanged: {
							updateRotationMatrix()
						}
					}
				}

				Row {
					spacing: mainScreen.gap

					property real side: Math.min( (controlLayout.width - mainScreen.gap)/2, controlLayout.height )

					FullDial {
						id: dialItem1
						width: parent.side
						height: parent.side
						color: "#203020"
						property real animatedValue: 0.0
						property real animatedOffset: 0.0
						onValueChanged: {
							updateRotationMatrix()
							animatedOffset = value - animatedValue
						}
						onAnimatedValueChanged: {
							value = animatedValue + animatedOffset
						}
					}

					FullDial {
						id: dialItem2
						width: parent.side
						height: parent.side
						color: "#203020"
						enabled: (doublerotCheckBox.checkState == Qt.Checked) && (isoclinicrotCheckBox.checkState == Qt.Unchecked)
						onValueChanged: {
							updateRotationMatrix()
						}
					}
				}
			}
		}

		// ---------- Full Control ----------

		Rectangle {
			anchors.fill: parent
			color: Qt.lighter( mainScreen.color, 1.2 )

			Grid {
				id: gridLayout
				columns: 3
				spacing: mainScreen.gap
				Repeater {
					id: allDials
					model: mainScreen._PLANES
					Item {
						width: side
						height: side
						property real side: Math.min( (controlLayout.width - mainScreen.gap*2)/3, (controlLayout.height - mainScreen.gap)/2 )
						property real value: 0.0
						Text {
							x: 1
							y: 1
							width: parent.width/2
							height: parent.height/10
							color: "#6060B0"
							font.bold: true
							font.pixelSize: height
							text: modelData
							
						}
						FullDial {
							anchors.fill: parent
							color: "#203020"							
							onValueChanged: {
								parent.value = value
								updateRotationMatrix()
							}
						}
					}
				}
			}
		}

		Rectangle {
			anchors.fill: parent
			color: Qt.lighter( mainScreen.color, 1.2 )

			property real side: Math.min( (controlLayout.width - mainScreen.gap)/2, controlLayout.height )

			FullDial {
				id: dialItemSpec
				width: parent.side
				height: parent.side
				color: "#203020"
				property real animatedValue: 0.0
				property real animatedOffset: 0.0
				onValueChanged: {
					updateRotationMatrix()
					animatedOffset = value - animatedValue
				}
				onAnimatedValueChanged: {
					value = animatedValue + animatedOffset
				}
			}

			StyledCheckBox {
				id: specAnimateCheckBox
				x: dialItemSpec.x + dialItemSpec.width + mainScreen.gap
				y: mainScreen.gap
				width: parent.w - mainScreen.gap
				height: mainScreen.height * 0.1
				text: qsTr("Animate")
				checkState: Qt.Unchecked
				onCheckStateChanged: {
					updateRotationMatrix()
				}
			}
		}

		onCurrentIndexChanged: {
			updateRotationMatrix()
		}

	} // end StackLayout

	NumberAnimation {
		target: dialItem1
		property: "animatedValue"
		duration: 10000
		from: 0
		to: 360
		loops: Animation.Infinite
		running: true
		paused: animateCheckBox.checkState == Qt.Unchecked
	}

	NumberAnimation {
		target: dialItemSpec
		property: "animatedValue"
		duration: 10000
		from: 0
		to: 360
		loops: Animation.Infinite
		running: true
		paused: specAnimateCheckBox.checkState == Qt.Unchecked
	}

	/*------------------------------------------------------------------*+
	|                                 MATH                               |
	+*------------------------------------------------------------------*/

	Rotate4DMat { id: basicRotMat }
	Rotate4DMat { id: allRotMat }
	Rotate4DMat { id: specRotMat }

	// define path of special rotations
	Item {
		id: specData

		property variant inputVal:   [ 0.0,  90.0, 180.0, 270.0, 360.0 ]
		property variant outputMap1: [ 0.0, -30.0, -60.0, -30.0,   0.0 ]
		property variant outputMap2: [ 0.0,  60.0,   0.0,   0.0,   0.0 ]
		property variant outputMap3: [ 0.0,   0.0,   0.0, -60.0,   0.0 ]

		function getVal( value, outmap ) {
			for ( var i=0; i<inputVal.length-1; ++i ) {
				if ( (value >= inputVal[i]) && (value <= inputVal[i+1]) ) {
					var a = (value - inputVal[i]) / (inputVal[i+1] - inputVal[i])
					//var aa = a;
					var aa = -Math.cos( a * Math.PI )/2 + 0.5
					//var aa = 1.0 / ( 1.0 + Math.exp( -(a-0.5)*10 ) )
					return aa*outmap[i+1] + (1.0-aa)*outmap[i]
				}
			}
			return 0.0
		}

		function get1( value ) { return getVal( value, outputMap1 ) }
		function get2( value ) { return getVal( value, outputMap2 ) }
		function get3( value ) { return getVal( value, outputMap3 ) }
	}

	function updateRotationMatrix() {

		function getComplementerPlaneIndex( planeIndex ) {
			var planeName = mainScreen._PLANES[planeIndex]
			for ( var i=0; i<mainScreen._PLANES.length; ++i ) {
				if (
					(!mainScreen._PLANES[i].includes(planeName.charAt(0))) &&
					(!mainScreen._PLANES[i].includes(planeName.charAt(1)))
				) {
					return i
				}
			}
		}

		if (tabBar.currentIndex == 0) {

			// --- BASIC CONTROL ---
			var angles = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
			var planeIndex = planeSelectorCombo.currentIndex

			if ( doublerotCheckBox.checkState==Qt.Unchecked ) {
				// simple rotation
				angles[ planeIndex ] = dialItem1.value
			} else if ( isoclinicrotCheckBox.checkState==Qt.Unchecked ) {
				// double rotation
				angles[ planeIndex ] = dialItem1.value
				angles[ getComplementerPlaneIndex(planeIndex) ] = dialItem2.value
			} else {
				// isoclinic rotation
				angles[ planeIndex ] = dialItem1.value
				angles[ getComplementerPlaneIndex(planeIndex) ] = dialItem1.value
			}

			basicRotMat.angles = angles
			pentachoronEntity.rotationMatrix = basicRotMat.matR

		}

		if (tabBar.currentIndex == 1) {

			// --- FULL CONTROL ---
			allRotMat.angles = [
				allDials.itemAt(0).value,
				allDials.itemAt(1).value,
				allDials.itemAt(2).value,
				allDials.itemAt(3).value,
				allDials.itemAt(4).value,
				allDials.itemAt(5).value
			]
			pentachoronEntity.rotationMatrix = allRotMat.matR

		}

		if (tabBar.currentIndex == 2) {

			// --- SPECIAL CONTROL ---
			var value = (dialItemSpec.value + 360.0) % 360.0
			specRotMat.angles = [ specData.get1(value), 0.0, specData.get2(value), 0.0, specData.get3(value), 0.0 ]
			pentachoronEntity.rotationMatrix = specRotMat.matR

		}

	}

	/*------------------------------------------------------------------*+
	|                         KEYBOARD HANDLERS                          |
	+*------------------------------------------------------------------*/

	Keys.onReleased: {
		page.handleBackKeyEvent( event, "" )
	}

}
