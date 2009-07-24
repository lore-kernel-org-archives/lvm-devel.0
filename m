From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jul 2009 23:29:14 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/config/d ...
Message-ID: <20090724232914.14797.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-24 23:29:04

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/config     : defaults.h 
	lib/locking    : locking.c 
	man            : lvm.conf.5.in 

Log message:
	Add global/wait_for_locks to lvm.conf so blocking on locks can be disabled.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1201&r2=1.1202
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2009/07/24 18:15:06	1.1201
+++ LVM2/WHATS_NEW	2009/07/24 23:28:55	1.1202
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Add global/wait_for_locks to lvm.conf so blocking for locks can be disabled.
   All LV locks are non-blocking so remove LCK_NONBLOCK from separate macros.
   Fix race condition with vgcreate and vgextend on same device (2.02.49).
   Remove redundant validate_name call from vgreduce.
--- LVM2/doc/example.conf	2009/07/06 19:04:25	1.41
+++ LVM2/doc/example.conf	2009/07/24 23:29:03	1.42
@@ -247,6 +247,9 @@
     # Type 3 uses built-in clustered locking.
     locking_type = 1
 
+    # Set to 0 to fail when a lock request cannot be satisfied immediately.
+    wait_for_locks = 1
+
     # If using external locking (type 2) and initialisation fails,
     # with this set to 1 an attempt will be made to use the built-in
     # clustered locking.
--- LVM2/lib/config/defaults.h	2009/07/09 10:00:36	1.46
+++ LVM2/lib/config/defaults.h	2009/07/24 23:29:03	1.47
@@ -39,6 +39,7 @@
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
 #define DEFAULT_FALLBACK_TO_LOCAL_LOCKING 1
 #define DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING 1
+#define DEFAULT_WAIT_FOR_LOCKS 1
 
 #define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
--- LVM2/lib/locking/locking.c	2009/07/24 18:15:07	1.63
+++ LVM2/lib/locking/locking.c	2009/07/24 23:29:03	1.64
@@ -35,6 +35,7 @@
 static int _vg_lock_count = 0;		/* Number of locks held */
 static int _vg_write_lock_held = 0;	/* VG write lock held? */
 static int _signals_blocked = 0;
+static int _blocking_supported = 0;
 
 static volatile sig_atomic_t _sigint_caught = 0;
 static volatile sig_atomic_t _handler_installed;
@@ -217,7 +218,9 @@
 {
 	if (type < 0)
 		type = find_config_tree_int(cmd, "global/locking_type", 1);
-		
+
+	_blocking_supported = find_config_tree_int(cmd,
+	    "global/wait_for_locks", DEFAULT_WAIT_FOR_LOCKS);
 	
 	switch (type) {
 	case 0:
@@ -227,7 +230,9 @@
 		return 1;
 
 	case 1:
-		log_very_verbose("File-based locking selected.");
+		log_very_verbose("%sFile-based locking selected.",
+				 _blocking_supported ? "" : "Non-blocking ");
+
 		if (!init_file_locking(&_locking, cmd))
 			break;
 		return 1;
@@ -379,7 +384,7 @@
 		 * This will enforce correctness and prevent deadlocks rather
 		 * than relying on the caller to set the flag properly.
 		 */
-		if (vgs_locked())
+		if (!_blocking_supported || vgs_locked())
 			flags |= LCK_NONBLOCK;
 
 		/* Lock VG to change on-disk metadata. */
--- LVM2/man/lvm.conf.5.in	2009/07/06 19:04:25	1.3
+++ LVM2/man/lvm.conf.5.in	2009/07/24 23:29:03	1.4
@@ -270,6 +270,10 @@
 All changes to logical volumes and their states are communicated
 using locks.
 .IP
+\fBwait_for_locks\fP \(em When set to 1, the default, the tools
+wait if a lock request cannot be satisfied immediately.
+When set to 0, the operation is aborted instead.
+.IP
 \fBlocking_dir\fP \(em The directory LVM2 places its file locks
 if \fBlocking_type\fP is set to 1.  The default is \fB/var/lock/lvm\fP.
 .IP


