From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 May 2009 10:12:35 -0000
Subject: LVM2/daemons/dmeventd Makefile.in
Message-ID: <20090511101235.14423.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-11 10:12:35

Modified files:
	daemons/dmeventd: Makefile.in 

Log message:
	Do not use generic install if running install_device-mapper.
	
	It propagates into subdirs which includes DSOs which requires
	lvm2 build (only install_device-mapper should propagate there).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/daemons/dmeventd/Makefile.in	2009/04/08 14:04:35	1.24
+++ LVM2/daemons/dmeventd/Makefile.in	2009/05/11 10:12:35	1.25
@@ -63,7 +63,7 @@
 
 install: $(INSTALL_TYPE) install_include install_dmeventd
 
-install_device-mapper: install
+install_device-mapper: $(INSTALL_TYPE) install_include install_dmeventd
 
 install_include:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper-event.h \


