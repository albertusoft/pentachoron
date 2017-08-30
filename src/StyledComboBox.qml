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

import QtQuick 2.6
import QtQuick.Controls 2.1

ComboBox {
	id: control
	model: ["First", "Second", "Third"]

	property color styleColor: "#606060"

	background: Rectangle {
		implicitWidth: 120
		implicitHeight: 40
		color: control.styleColor
		border.color: control.pressed ? Qt.lighter(control.styleColor,1.2) : control.styleColor
		border.width: control.visualFocus ? 2 : 1
		radius: 5
	}

	indicator: Canvas {
		id: canvas
		x: control.width - width - control.rightPadding
		y: control.topPadding + (control.availableHeight - height) / 2
		width: 12
		height: 8
		contextType: "2d"

		Connections {
			target: control
			onPressedChanged: canvas.requestPaint()
		}

		onPaint: {
			context.reset();
			context.moveTo(0, 0);
			context.lineTo(width, 0);
			context.lineTo(width / 2, height);
			context.closePath();
			context.fillStyle = control.pressed ? Qt.darker(control.styleColor,1.3) : Qt.darker(control.styleColor,2.5);
			context.fill();
		}
	}

	contentItem: Text {
		leftPadding: 0
		rightPadding: control.indicator.width + control.spacing
		text: control.displayText
		font.bold: true
		font.pixelSize: control.width/4
		color: control.pressed ? Qt.lighter(control.styleColor,7.0) : Qt.lighter(control.styleColor,4.0)
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
	}

	// popup box
	popup: Popup {
		y: control.height - 1
		width: control.width
		implicitHeight: contentItem.implicitHeight
		padding: 1

		contentItem: ListView {
			clip: true
			implicitHeight: contentHeight
			model: control.popup.visible ? control.delegateModel : null
			currentIndex: control.highlightedIndex

			ScrollIndicator.vertical: ScrollIndicator { }
		}

		background: Rectangle {
			color: Qt.darker(control.styleColor,1.5)
			border.color: Qt.darker(control.styleColor,1.2)
			border.width: 2
			radius: 5
		}
	}

	// popup items
	delegate: ItemDelegate {
		width: control.width
		contentItem: Text {
			text: modelData
			color: Qt.lighter(control.styleColor,2.0)
			font.bold: true
			font.pixelSize: control.width/4
			elide: Text.ElideRight
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
		}
		highlighted: control.highlightedIndex === index
	}
}
