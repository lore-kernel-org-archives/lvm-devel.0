From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Nov 2010 21:39:48 -0000
Subject: LVM2 Makefile.in WHATS_NEW
Message-ID: <20101122213948.11757.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-22 21:39:47

Modified files:
	.              : Makefile.in WHATS_NEW 

Log message:
	Fix default /etc/lvm permissions to be 0755. (2.02.66)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1800&r2=1.1801

--- LVM2/Makefile.in	2010/08/09 10:56:01	1.62
+++ LVM2/Makefile.in	2010/11/22 21:39:47	1.63
@@ -81,7 +81,7 @@
 	$(MAKE) -C test $(@)
 
 install_system_dirs:
-	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_SYS_DIR)
+	$(INSTALL_DIR) $(DESTDIR)$(DEFAULT_SYS_DIR)
 	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_ARCHIVE_DIR)
 	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_BACKUP_DIR)
 	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_CACHE_DIR)
--- LVM2/WHATS_NEW	2010/11/22 18:37:56	1.1800
+++ LVM2/WHATS_NEW	2010/11/22 21:39:47	1.1801
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix default /etc/lvm permissions to be 0755. (2.02.66)
 
 Version 2.02.77 - 22nd November 2010
 ====================================


