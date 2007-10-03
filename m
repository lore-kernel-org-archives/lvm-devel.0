From: meyering@sourceware.org <meyering@sourceware.org>
Date: 3 Oct 2007 09:46:58 -0000
Subject: LVM2/tools/fsadm Makefile.in
Message-ID: <20071003094658.15588.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-10-03 09:46:58

Modified files:
	tools/fsadm    : Makefile.in 

Log message:
	Avoid link failure when building fsadm.
	
	* tools/fsadm/Makefile.in (LVMLIBS): Define.
	(fsadm): Link with $(LVMLIBS).
	
	Author: Nix <nix@esperi.org.uk>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/fsadm/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/tools/fsadm/Makefile.in	2007/09/21 10:16:45	1.3
+++ LVM2/tools/fsadm/Makefile.in	2007/10/03 09:46:57	1.4
@@ -20,10 +20,12 @@
 
 TARGETS = fsadm
 
+LVMLIBS = -llvm
+
 include $(top_srcdir)/make.tmpl
 
 fsadm: $(OBJECTS)
-	$(CC) -o $@ $(CFLAGS) $(OBJECTS) -rdynamic
+	$(CC) -o $@ $(CFLAGS) $(OBJECTS) $(LDFLAGS) $(LVMLIBS) -rdynamic
 
 install: fsadm
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) fsadm \


