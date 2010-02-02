From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Feb 2010 14:09:18 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM daemons/dmeven ...
Message-ID: <20100202140918.25779.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-02-02 14:09:18

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 

Log message:
	Remove pointless versioned symlinks to dmeventd plugin libraries.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1415&r2=1.1416
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.342&r2=1.343
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2010/02/02 14:03:50	1.1415
+++ LVM2/WHATS_NEW	2010/02/02 14:09:17	1.1416
@@ -1,5 +1,7 @@
 Version 2.02.61 - 
 ===================================
+  Remove pointless versioned symlinks to dmeventd plugin libraries.
+  Fix dmeventd snapshot plugin build dependency.
   Make clvmd -V return zero status.
 
 Version 2.02.60 - 23rd January 2010
--- LVM2/WHATS_NEW_DM	2010/02/02 14:03:50	1.342
+++ LVM2/WHATS_NEW_DM	2010/02/02 14:09:17	1.343
@@ -1,6 +1,5 @@
 Version 1.02.44 - 
 ===================================
-  Fix dmeventd snapshot plugin build dependency.
 
 Version 1.02.43 - 21st January 2010
 ===================================
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/01/21 22:15:46	1.13
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/02/02 14:09:18	1.14
@@ -36,7 +36,6 @@
 
 install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$<.$(LIB_VERSION)
-	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
+		$(libdir)/$<
 
 install: install_lvm2
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/01/21 22:15:46	1.9
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/02/02 14:09:18	1.10
@@ -36,7 +36,6 @@
 
 install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$<.$(LIB_VERSION)
-	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
+		$(libdir)/$<
 
 install: install_lvm2


