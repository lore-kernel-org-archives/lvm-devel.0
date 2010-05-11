From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 May 2010 08:42:00 -0000
Subject: LVM2/daemons/dmeventd/plugins mirror/Makefile. ...
Message-ID: <20100511084200.4848.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-11 08:42:00

Modified files:
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 

Log message:
	Plugins do not use pthread or lvm2cmd directly.
	
	Plugins are using pthread and lvm2cmd libraries indirectly
	through devmapper-event-lvm2, so link only with libraries used by them.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/05/06 10:07:47	1.20
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/05/11 08:41:58	1.21
@@ -30,7 +30,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
+LIBS += -ldevmapper-event-lvm2 -ldevmapper
 
 install_lvm2: install_dm_plugin
 
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/05/06 10:07:47	1.15
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/05/11 08:41:59	1.16
@@ -26,7 +26,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
+LIBS += -ldevmapper-event-lvm2 -ldevmapper
 
 install_lvm2: install_dm_plugin
 


