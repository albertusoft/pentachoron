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

CheckBox {
	id: control
	text: qsTr("CheckBox")
	checked: true

	indicator: Rectangle {
		implicitWidth: 26
		implicitHeight: 26
		x: control.leftPadding
		y: parent.height / 2 - height / 2
		radius: 3
		border.color: control.down ? "#17a81a" : "#21be2b"

		Rectangle {
			width: 14
			height: 14
			x: 6
			y: 6
			radius: 2
			color: control.down ? "#17a81a" : "#21be2b"
			visible: control.checked
		}
	}

	contentItem: Text {
		text: control.text
		font: control.font
		opacity: enabled ? 1.0 : 0.3
		color: control.down ? "#17a81a" : "#21be2b"
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		leftPadding: control.indicator.width + control.spacing
	}
}
