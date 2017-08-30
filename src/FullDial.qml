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

Item {
	id: control

	property real from: 0.0
	property real to: 360.0
	property real value: 0.0

	property color color: "#404040"
	property color textColor: Qt.lighter( color, 3.0 )
	property string unitSign: "°"

	property real borderSize: width * 0.02
	property real middleSize: width * 0.4
	property real handleSize: side * 0.1

	property int actionCount: 0

	property real side: (width < height) ? width : height

	// the dial
	Rectangle {
		x: control.borderSize
		y: control.borderSize
		width: control.width - 2*control.borderSize
		height: control.height - 2*control.borderSize
		radius: side/2
		color: control.color
		opacity: control.enabled ? 1.0 : 0.33
		border.width: borderSize
		border.color: Qt.lighter( control.color, 1.5 )

		property real side: (width < height) ? width : height
	}

	// middle
	Rectangle {
		x: control.width/2 - control.middleSize/2
		y: control.height/2 - control.middleSize/2
		width: control.middleSize
		height: control.middleSize
		radius: side/2
		color: Qt.darker( control.color, 1.5 )
		opacity: control.enabled ? 1.0 : 0.33

		property real side: (width < height) ? width : height
	}

	// handle
	Rectangle {
		x: control.width/2  + Math.cos( value * Math.PI/180 ) * (control.width*0.45 - handleSize) - control.handleSize/2
		y: control.height/2 - Math.sin( value * Math.PI/180 ) * (control.width*0.45 - handleSize) - control.handleSize/2
		width: control.handleSize
		height: control.handleSize
		radius: side/2
		color: Qt.darker( control.color, 1.3 )
		opacity: control.enabled ? 1.0 : 0.33

		property real side: (width < height) ? width : height
	}

	// mouse tracking
	MouseArea {
		anchors.fill: control
		onPressed: { handle(mouse,0.5) }
		onPositionChanged: { handle(mouse,0) }
		onDoubleClicked: { handle(mouse,2) }
		function handle( mouse, clicknum ) {
			var r = Qt.vector2d( mouse.y/height-0.5, mouse.x/width-0.5 ).length() * 2.0
			if ( r < control.middleSize / control.width / 2 ) {
				if ( clicknum > 1 ) {
					control.value = 0.0
				}
			}
			else if ( r <= 1.0 ) {
				var a = -Math.atan2( mouse.y/height-0.5, mouse.x/width-0.5 ) / (2*Math.PI)
				control.value = from * (1.0-a) + to * a
			}
			actionCount += 1
		}
	}

	Text {
		x: control.width/2 - control.middleSize/2
		y: control.height/2 - control.middleSize/2
		width: control.middleSize
		height: control.middleSize
		color: control.textColor
		opacity: control.enabled ? 1.0 : 0.33
		text: "" + control.value.toFixed(1) + control.unitSign
		font.bold: true
		font.pixelSize: control.middleSize / 5
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}
}
