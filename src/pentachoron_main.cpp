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

#include <QGuiApplication>
#include <QApplication>
#include <QQuickView>
#include <QtGui>
#include <QtQuick>
#include <QScreen>

#include "Utils.h"


int main( int argc, char *argv[] )
{
	QApplication app(argc, argv);

	// cortexview library component initialization
	Q_INIT_RESOURCE(pentachoron);

	Utils::registerTypes();

	// main window
	QQuickView view;
	QSurfaceFormat format = view.format();
	format.setSamples(16);
	view.setFormat(format);
	view.setSource( QUrl(QStringLiteral("qrc:/pentachoron_main.qml")) );

	//if ( engine.rootObjects().isEmpty() ) return -1;

#ifdef __ANDROID__
	view.showMaximized();
#else
	QScreen *screen = QGuiApplication::primaryScreen();
	QSize screenSize = screen->virtualSize();
#ifdef WIN32
    QSize winSize(450,800);
#else
    QSize winSize(540,960);
#endif
	view.setWidth( winSize.width() );
	view.setHeight( winSize.height() );
	view.setX( (screenSize.width() - winSize.width()) / 2 );
	view.setY( (screenSize.height() - winSize.height()) / 2 );
	view.show();
#endif

	// connect the quit signal, thus we will able to use it from QML code
	view.connect( view.engine(), SIGNAL(quit()), &app, SLOT(quit()) );

	return app.exec();
}

