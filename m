From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Mar 2010 18:33:56 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/libdevmapper ...
Message-ID: <20100319183356.30453.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-19 18:33:55

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: libdevmapper-event.pc.in 

Log message:
	Fix libdevmapper-event pkgconfig version string to match libdevmapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1470&r2=1.1471
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.pc.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2010/03/18 17:32:25	1.1470
+++ LVM2/WHATS_NEW	2010/03/19 18:33:55	1.1471
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Fix libdevmapper-event pkgconfig version string to match libdevmapper.
   Avoid scanning all pvs in the system if operating on a device with mdas.
   Add configure --with-clvmd=singlenode to use clvmd w/o cluster infrastructure.
   Get stacktrace if testsuite test drops core and lvm was built with debugging.
--- LVM2/daemons/dmeventd/libdevmapper-event.pc.in	2006/04/19 15:23:10	1.1
+++ LVM2/daemons/dmeventd/libdevmapper-event.pc.in	2010/03/19 18:33:55	1.2
@@ -5,7 +5,7 @@
 
 Name: devmapper-event
 Description: device-mapper event library
-Version: @DM_LIB_VERSION@
+Version: @DM_LIB_PATCHLEVEL@
 Requires: devmapper
 Cflags: -I${includedir}
 Libs: -L${libdir} -ldevmapper-event


