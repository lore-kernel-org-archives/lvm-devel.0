From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Jan 2011 12:59:47 -0000
Subject: LVM2 ./WHATS_NEW tools/polldaemon.c
Message-ID: <20110105125947.30840.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-05 12:59:47

Modified files:
	.              : WHATS_NEW 
	tools          : polldaemon.c 

Log message:
	Fail deamonization if lvmcache_init fail
	
	FIXME Add proper cleanup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1858&r2=1.1859
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/WHATS_NEW	2011/01/05 12:33:51	1.1858
+++ LVM2/WHATS_NEW	2011/01/05 12:59:46	1.1859
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Fail poll daemon creation when lvmcache_init() fails.
   Return defined value for errors in _copy_percent() and _snap_percent().
   Correct return code of cmirrord when issuing 'start' when already running.
   Fix wrongly paired unlocking of global lock in pvchange. (2.02.66)
--- LVM2/tools/polldaemon.c	2010/12/08 20:50:51	1.39
+++ LVM2/tools/polldaemon.c	2011/01/05 12:59:47	1.40
@@ -64,7 +64,9 @@
 	strncpy(*cmd->argv, "(lvm2)", strlen(*cmd->argv));
 
 	reset_locking();
-	lvmcache_init();
+	if (!lvmcache_init())
+		/* FIXME Clean up properly here */
+		_exit(ECMD_FAILED);
 	dev_close_all();
 
 	return 1;


