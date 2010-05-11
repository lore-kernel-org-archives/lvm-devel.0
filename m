From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 May 2010 08:38:13 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/Makefile.in
Message-ID: <20100511083813.4053.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-11 08:38:11

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: Makefile.in 

Log message:
	Link libdevmapper-event.so with libdevmapper.so.
	For now using $(LIBS) for a list of linked libraries to $(LIB_SHARED) library.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1551&r2=1.1552
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2010/05/11 08:34:38	1.1551
+++ LVM2/WHATS_NEW	2010/05/11 08:38:10	1.1552
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Add devmapper library to linked libdevmapper-event.so.
   Link liblvm2cmd.so with devmapper-event and devmapper libs.
   Fix truncated total size displayed by pvscan.
   Add new --sysinit option for vgchange and lvchange.
--- LVM2/daemons/dmeventd/Makefile.in	2010/04/09 21:42:48	1.41
+++ LVM2/daemons/dmeventd/Makefile.in	2010/05/11 08:38:10	1.42
@@ -53,7 +53,8 @@
 all: device-mapper
 device-mapper: $(TARGETS)
 
-LVMLIBS += -ldevmapper-event -ldevmapper $(PTHREAD_LIBS)
+LIBS += -ldevmapper
+LVMLIBS += -ldevmapper-event $(PTHREAD_LIBS)
 
 dmeventd: $(LIB_SHARED) dmeventd.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -L. -o $@ dmeventd.o \


