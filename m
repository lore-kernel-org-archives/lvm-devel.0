From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 11 Dec 2006 14:00:29 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20061211140029.28590.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2006-12-11 14:00:27

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c clvmd-gulm.c clvmd-gulm.h 
	lib/locking    : locking.h 

Log message:
	Fix gulm operation of clvmd. including a hang when attempting to
	exclusively lock an LV that is already locked no another node.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.516&r2=1.517
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2006/12/11 13:48:41	1.516
+++ LVM2/WHATS_NEW	2006/12/11 14:00:26	1.517
@@ -1,5 +1,6 @@
 Version 2.02.17 -
 ===================================
+  Fix gulm operation of clvmd, including a hang when doing lvchange -aey
   Fix hang in clvmd if a pre-command failed.
 
 Version 2.02.16 - 1st December 2006
--- LVM2/daemons/clvmd/clvmd-command.c	2006/12/01 23:10:25	1.13
+++ LVM2/daemons/clvmd/clvmd-command.c	2006/12/11 14:00:26	1.14
@@ -194,7 +194,7 @@
 	/* Read locks need to be PR; other modes get passed through */
 	if ((lock_cmd & LCK_TYPE_MASK) == LCK_READ) {
 	    lock_cmd &= ~LCK_TYPE_MASK;
-	    lock_cmd |= LKM_PRMODE;
+	    lock_cmd |= LCK_PREAD;
 	}
 	status = sync_lock(lockname, (int)lock_cmd, (lock_flags & LCK_NONBLOCK) ? LKF_NOQUEUE : 0, &lkid);
 	if (status)
--- LVM2/daemons/clvmd/clvmd-gulm.c	2006/10/09 14:11:57	1.19
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2006/12/11 14:00:26	1.20
@@ -730,7 +730,7 @@
     pthread_mutex_lock(&lwait.mutex);
 
     /* This needs to be converted from DLM/LVM2 value for GULM */
-    if (flags == LCK_NONBLOCK) flags = lg_lock_flag_Try;
+    if (flags & LKF_NOQUEUE) flags = lg_lock_flag_Try;
 
     dm_hash_insert(lock_hash, resource, &lwait);
     DEBUGLOG("lock_resource '%s', flags=%d, mode=%d\n", resource, flags, mode);
@@ -828,6 +828,7 @@
         }
 	break;
 
+    case LCK_PREAD:
     case LCK_READ:
 	status = _lock_resource(lock1, lg_lock_state_Shared, flags, lockid);
 	if (status)
@@ -864,6 +865,7 @@
     /* The held lock mode is in the lock id */
     assert(lockid == LCK_EXCL ||
 	   lockid == LCK_READ ||
+	   lockid == LCK_PREAD ||
 	   lockid == LCK_WRITE);
 
     status = _unlock_resource(lock1, lockid);
--- LVM2/daemons/clvmd/clvmd-gulm.h	2005/01/13 13:24:02	1.2
+++ LVM2/daemons/clvmd/clvmd-gulm.h	2006/12/11 14:00:26	1.3
@@ -1,5 +1,6 @@
 
-
+/* DLM constant that clvmd uses as a generic NONBLOCK lock flag */
+#define LKF_NOQUEUE 1
 
 extern int get_next_node_csid(void **context, char *csid);
 extern void add_down_node(char *csid);
--- LVM2/lib/locking/locking.h	2006/05/16 16:48:30	1.28
+++ LVM2/lib/locking/locking.h	2006/12/11 14:00:26	1.29
@@ -50,7 +50,7 @@
 #define LCK_NULL	0x00000000	/* LCK$_NLMODE */
 #define LCK_READ	0x00000001	/* LCK$_CRMODE */
 					/* LCK$_CWMODE */
-					/* LCK$_PRMODE */
+#define LCK_PREAD       0x00000003      /* LCK$_PRMODE */
 #define LCK_WRITE	0x00000004	/* LCK$_PWMODE */
 #define LCK_EXCL	0x00000005	/* LCK$_EXMODE */
 #define LCK_UNLOCK      0x00000006	/* This is ours */


