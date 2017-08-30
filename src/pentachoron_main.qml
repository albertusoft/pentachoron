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
	id: page
	anchors.fill: parent
	focus: false

	MainScreen {
		id: mainScreen
		x: 0
		y: 0
		z: 0
		width: page.width
		height: page.height
	}

	HelpScreen {
		id: helpScreen
		x: page.width+1
		y: 0
		z: 10
		width: page.width
		height: page.height
	}

	LicenseScreen {
		id: licensesScreen
		x: page.width*2+1
		y: 0
		z: 10
		width: page.width
		height: page.height
	}

	states: [
		State {
			name: ""
			PropertyChanges {
				target: mainScreen
				x: 0
				y: 0
				focus: true
			}
			PropertyChanges {
				target: helpScreen
				x: page.width+1
				y: 0
				focus: false
			}
			PropertyChanges {
				target: licensesScreen
				x: page.width*2+1
				y: 0
				focus: false
			}
		},
		State {
			name: "HELP"
			PropertyChanges {
				target: mainScreen
				x: -page.width-1
				y: 0
				focus: false
			}
			PropertyChanges {
				target: helpScreen
				x: 0
				y: 0
				focus: true
			}
			PropertyChanges {
				target: licensesScreen
				x: page.width+1
				y: 0
				focus: false
			}
		},
		State {
			name: "LICENSES@HELP"
			PropertyChanges {
				target: mainScreen
				x: -page.width*2-1
				y: 0
				focus: false
			}
			PropertyChanges {
				target: helpScreen
				x: -page.width-1
				y: 0
				focus: false
			}
			PropertyChanges {
				target: licensesScreen
				x: 0
				y: 0
				focus: true
			}
		}
	]

	transitions: [
		Transition {
			from: ""
			to: "HELP"
			reversible: true
			ParallelAnimation {
				DefaultNumberAnimation { target: mainScreen }
				DefaultNumberAnimation { target: helpScreen }
				DefaultNumberAnimation { target: licensesScreen }
			}
		},
		Transition {
			from: "HELP"
			to: "LICENSES@HELP"
			reversible: true
			ParallelAnimation {
				DefaultNumberAnimation { target: mainScreen }
				DefaultNumberAnimation { target: helpScreen }
				DefaultNumberAnimation { target: licensesScreen }
			}
		}
	]

	/*------------------------------------------------------------------*+
	|                         KEYBOARD HANDLERS                          |
	+*------------------------------------------------------------------*/

	Keys.onReleased: {
		console.log( "page.Keys.onReleased.event=" + event );
		page.handleBackKeyEvent( event, "" )
	}

	function handleBackKeyEvent( aEvent, aBaseState ) {
		if ( [ Qt.Key_Back, Qt.Key_Escape ].indexOf( aEvent.key ) >= 0 ) {
			aEvent.accepted = true
			console.log("handleBackKeyEvent('"+page.state+"'->'"+aBaseState+"')");
			if ( page.state == "" )
			{
				console.log("quit");
				Qt.quit();
			}
			if ( (aBaseState == "") && (page.state.indexOf('@') > 0) ) {
				aBaseState = page.state.substring( page.state.indexOf('@')+1 )
			}
			page.state = aBaseState
		}
	}

}
