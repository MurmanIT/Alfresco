#!/bin/sh -e

SOFFICE_ROOT=/usr/bin
USER=alfresco

/bin/su -s /bin/bash $USER -c $SOFFICE_ROOT"/soffice \"--accept=socket,host=localhost,port=8100;urp;StarOffice.ServiceManager\" \"-env:UserInstallation=file:///opt/alfresco/alf_data/oouser\" --nologo --headless --nofirststartwizard --norestore --nodefault &" >/dev/nul

#TODO create service start|stop|restart ?
