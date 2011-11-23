From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2011 13:02:17 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20111123130217.3959.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-23 13:02:17

Modified files:
	test/api       : Makefile.in 

Log message:
	Put back devmapper-event linkage
	
	Older systems are not able to get this library from lvm2api library and need
	this library to be passed to the linker (i.e. Debian Lenny).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/test/api/Makefile.in	2011/11/23 12:21:41	1.23
+++ LVM2/test/api/Makefile.in	2011/11/23 13:02:17	1.24
@@ -28,7 +28,14 @@
 DEFS += -D_REENTRANT
 DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
 LDFLAGS += -L$(top_builddir)/liblvm
-LVMLIBS = @LVM2APP_LIB@ -ldevmapper $(LIBS)
+LVMLIBS = @LVM2APP_LIB@ -ldevmapper
+
+ifeq ("@DMEVENTD@", "yes")
+       LVMLIBS += -ldevmapper-event
+       LDFLAGS += -L$(top_builddir)/daemons/dmeventd
+endif
+
+LVMLIBS += $(LIBS)
 
 %.t: %.o $(DEPLIBS)
 	$(CC) -o $@ $(<) $(LDFLAGS) $(LVMLIBS)


