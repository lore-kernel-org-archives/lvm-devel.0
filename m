From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Dec 2010 12:56:40 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20101201125640.12011.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-01 12:56:39

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Add backtraces for errors
	
	Add stack;  backtraces when error is reported from dev_set() or
	dev_close_immediate().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1823&r2=1.1824
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.238&r2=1.239

--- LVM2/WHATS_NEW	2010/12/01 12:41:49	1.1823
+++ LVM2/WHATS_NEW	2010/12/01 12:56:39	1.1824
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Add backtraces for dev_set() and dev_close_immediate() errors in set_lv().
   Add logging for unlink() error in clvmd remove_lockfile().
   Add logging for pipe write() and close() error in clvmd child_init_signal().
   Add test for existance of orphan vginfo in _lvmcache_update_vgname().
--- LVM2/lib/metadata/lv_manip.c	2010/11/11 17:29:06	1.238
+++ LVM2/lib/metadata/lv_manip.c	2010/12/01 12:56:39	1.239
@@ -3033,9 +3033,13 @@
 	if (sectors > lv->size)
 		sectors = lv->size;
 
-	dev_set(dev, UINT64_C(0), (size_t) sectors << SECTOR_SHIFT, value);
+	if (!dev_set(dev, UINT64_C(0), (size_t) sectors << SECTOR_SHIFT, value))
+		stack;
+
 	dev_flush(dev);
-	dev_close_immediate(dev);
+
+	if (!dev_close_immediate(dev))
+                stack;
 
 	return 1;
 }


