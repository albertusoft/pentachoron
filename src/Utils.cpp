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

#include "Utils.h"
#include <QDebug>

// created instance will be destroyed by QML engine,
// if QML engine is not used then destry it manually at end of use
Utils& Utils::getInstance()
{
	static Utils* instance = new Utils();
	return *instance;
}


Utils::Utils()
{
	qDebug() << "Utils::constructor()";
}


Utils::~Utils()
{
	qDebug() << "Utils::destructor()";
}


// define the singleton type provider function (callback).
static QObject* singletontype_provider(QQmlEngine *aEngine, QJSEngine *aScriptEngine)
{
	Q_UNUSED(aEngine);
	Q_UNUSED(aScriptEngine);
	return &Utils::getInstance();
}


void Utils::registerTypes()
{
	qmlRegisterSingletonType<Utils>( "Utils", 1, 0, "UtilsCore", singletontype_provider );
}


QByteArray Utils::readFile( const QString &aFileName )
{
	QFile file( aFileName );

	if ( !file.open(QIODevice::ReadOnly) )
	{
		return QByteArray();
	}

	return file.readAll();
}
