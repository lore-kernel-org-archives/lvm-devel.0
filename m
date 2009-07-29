From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jul 2009 19:24:12 -0000
Subject: LVM2 ./WHATS_NEW liblvm/Makefile.in
Message-ID: <20090729192412.2939.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-29 19:24:12

Modified files:
	.              : WHATS_NEW 
	liblvm         : Makefile.in 

Log message:
	Fix lvm2app.pc installation filename.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1209&r2=1.1210
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW	2009/07/29 13:26:01	1.1209
+++ LVM2/WHATS_NEW	2009/07/29 19:24:11	1.1210
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Fix lvm2app.pc installation filename.
   Remove pv_t, vg_t & lv_t handles from lib.  Only liblvm uses them.
   Rename lvm.h to lvm2app.h for now.
 
--- LVM2/liblvm/Makefile.in	2009/07/29 13:26:01	1.12
+++ LVM2/liblvm/Makefile.in	2009/07/29 19:24:11	1.13
@@ -77,7 +77,7 @@
 
 install_pkgconfig:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(LIB_NAME).pc \
-		$(usrlibdir)/pkgconfig/$(LIB_NAME).pc
+		$(usrlibdir)/pkgconfig/lvm2app.pc
 
 liblvm.cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \


