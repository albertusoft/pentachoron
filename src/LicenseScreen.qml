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

import QtQuick 2.2
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.2
import Utils 1.0


Rectangle {

	id: screen
	color: "#000000"

	MouseArea {
		anchors.fill: parent
	}

	Flickable {
		anchors.fill: parent
		boundsBehavior: Flickable.StopAtBounds

		TextArea.flickable: TextArea {
			id: textArea
			wrapMode: TextArea.Wrap			
			readOnly: true
			font.pointSize: 18
			color: "white"
			textFormat: TextEdit.RichText
			text: ""

			Component.onCompleted: {
				text += UtilsCore.readFile( ":/resources/doc/qt-5.9-lgpl.html" )
			}

			onLinkActivated:  {
				console.log( "link=" + link )
				if ( link.startsWith("http") ) {
					Qt.openUrlExternally(link)
				}
				else if ( link.startsWith("state:") ) {
					page.state = link
				}
			}

			Keys.onReleased: {
				screen.Keys.onReleased( event )
			}
		}

		ScrollBar.vertical: ScrollBar { }

		Keys.onReleased: {
			screen.Keys.onReleased( event )
		}
	}

	/*------------------------------------------------------------------*+
	|                         KEYBOARD HANDLERS                          |
	+*------------------------------------------------------------------*/

	Keys.onReleased: {
		page.handleBackKeyEvent( event, "" )
	}

}