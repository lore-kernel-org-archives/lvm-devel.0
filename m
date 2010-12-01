From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Dec 2010 12:41:50 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20101201124150.3833.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-01 12:41:49

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Log error from unlink failure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1822&r2=1.1823
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/WHATS_NEW	2010/12/01 10:46:20	1.1822
+++ LVM2/WHATS_NEW	2010/12/01 12:41:49	1.1823
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Add logging for unlink() error in clvmd remove_lockfile().
   Add logging for pipe write() and close() error in clvmd child_init_signal().
   Add test for existance of orphan vginfo in _lvmcache_update_vgname().
   Do a full rescan if some device is missing in read_pvs_in_vg().
--- LVM2/daemons/clvmd/clvmd.c	2010/12/01 10:46:20	1.85
+++ LVM2/daemons/clvmd/clvmd.c	2010/12/01 12:41:49	1.86
@@ -289,7 +289,8 @@
 
 static void remove_lockfile(void)
 {
-	unlink(CLVMD_PIDFILE);
+	if (unlink(CLVMD_PIDFILE))
+		log_sys_error("unlink", CLVMD_PIDFILE);
 }
 
 /*


