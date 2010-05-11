From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 May 2010 08:47:05 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/libdevmapper ...
Message-ID: <20100511084705.7923.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-11 08:47:03

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: libdevmapper-event.pc.in 

Log message:
	Use Require.private: field for devmapper-event.pc
	
	Move devmapper to Require.private: field and remove unneeded libs
	from Libs.private: as they are dependencies of devmapper library.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1552&r2=1.1553
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.pc.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2010/05/11 08:38:10	1.1552
+++ LVM2/WHATS_NEW	2010/05/11 08:47:02	1.1553
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Use field Requires.private: for devmapper-event.pc.
   Add devmapper library to linked libdevmapper-event.so.
   Link liblvm2cmd.so with devmapper-event and devmapper libs.
   Fix truncated total size displayed by pvscan.
--- LVM2/daemons/dmeventd/libdevmapper-event.pc.in	2010/03/19 18:33:55	1.2
+++ LVM2/daemons/dmeventd/libdevmapper-event.pc.in	2010/05/11 08:47:03	1.3
@@ -6,7 +6,6 @@
 Name: devmapper-event
 Description: device-mapper event library
 Version: @DM_LIB_PATCHLEVEL@
-Requires: devmapper
 Cflags: -I${includedir}
 Libs: -L${libdir} -ldevmapper-event
-Libs.private: -lpthread -ldl
+Requires.private: devmapper


