
function Component() { }

Component.prototype.createOperations = function() {
	try {
		component.createOperations();
		if (installer.value("os") === "win") {
			try {
				component.addOperation( "CreateShortcut", "@APP__TargetDir__@/@APP_NAME@.exe", "@APP__StartMenuDir__@/pentachoron.lnk", "workingDirectory=@APP__TargetDir__@",  "description=@APP_DESCRIPTION@" );
				component.addOperation( "CreateShortcut", "@APP__TargetDir__@/@APP_NAME@.exe", "@APP__DesktopDir__@/pentachoron.lnk", "workingDirectory=@APP__TargetDir__@",  "description=@APP_DESCRIPTION@" );
			} catch (e) {}
		}
	} catch (e) {
		print(e);
	}
}
