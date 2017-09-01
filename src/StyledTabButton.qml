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

TabButton {
	id: control
	text: qsTr("Basic")

	property color bgColor: "#808080"
	property color textColor: "#FFFFFF"

	contentItem: Text {
		text: control.text
		font.family: control.font.family
		font.pixelSize: control.font.pixelSize
		font.bold: true
		opacity: enabled ? 1.0 : 0.3
		color: control.checked ? control.textColor : Qt.darker( control.textColor, 2.5 )
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
	}

	background: Rectangle {
		implicitWidth: 100
		implicitHeight: 40
		opacity: enabled ? 1 : 0.3
		color: control.checked ? Qt.lighter( control.bgColor, 1.6 ) : Qt.lighter( control.bgColor, 1.2 )
		border.color: control.checked ? Qt.lighter( control.bgColor, 2.0 ) : Qt.lighter( control.bgColor, 1.4 )
		border.width: 1
		radius: control.width/20
	}
}
