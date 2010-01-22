From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Jan 2010 09:45:31 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c lib/loc ...
Message-ID: <20100122094531.27340.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-22 09:45:30

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c no_locking.c 
	liblvm         : lvm_base.c 
	tools          : lvmcmdline.c 

Log message:
	Move error message to locking constructor and print
	more descriptive message if locking fails instead of
	"Locking type -1 initialisation failed."
	
	Use read-only locking instead of misleading ignorelocking option
	in message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1401&r2=1.1402
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/WHATS_NEW	2010/01/22 01:09:09	1.1401
+++ LVM2/WHATS_NEW	2010/01/22 09:45:29	1.1402
@@ -1,5 +1,6 @@
 Version 2.02.60
 ===================================
+  Fix failed locking messages to be more descriptive.
 
 Version 2.02.59 - 21st January 2010
 ===================================
--- LVM2/lib/locking/locking.c	2010/01/13 17:40:17	1.72
+++ LVM2/lib/locking/locking.c	2010/01/22 09:45:29	1.73
@@ -224,7 +224,7 @@
 
 	_blocking_supported = find_config_tree_int(cmd,
 	    "global/wait_for_locks", DEFAULT_WAIT_FOR_LOCKS);
-	
+
 	switch (type) {
 	case 0:
 		init_no_locking(&_locking, cmd);
@@ -236,8 +236,10 @@
 		log_very_verbose("%sFile-based locking selected.",
 				 _blocking_supported ? "" : "Non-blocking ");
 
-		if (!init_file_locking(&_locking, cmd))
+		if (!init_file_locking(&_locking, cmd)) {
+			log_error("File-based locking initialisation failed.");
 			break;
+		}
 		return 1;
 
 #ifdef HAVE_LIBDL
@@ -249,8 +251,10 @@
 		}
 		if (!find_config_tree_int(cmd, "locking/fallback_to_clustered_locking",
 			    find_config_tree_int(cmd, "global/fallback_to_clustered_locking",
-						 DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING)))
+						 DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING))) {
+			log_error("External locking initialisation failed.");
 			break;
+		}
 #endif
 
 #ifdef CLUSTER_LOCKING_INTERNAL
@@ -259,8 +263,10 @@
 
 	case 3:
 		log_very_verbose("Cluster locking selected.");
-		if (!init_cluster_locking(&_locking, cmd))
+		if (!init_cluster_locking(&_locking, cmd)) {
+			log_error("Internal cluster locking initialisation failed.");
 			break;
+		}
 		return 1;
 #endif
 
@@ -285,6 +291,8 @@
 			  "be inaccessible.");
 		if (init_file_locking(&_locking, cmd))
 			return 1;
+		else
+			log_error("File-based locking initialisation failed.");
 	}
 
 	if (!ignorelockingfailure())
--- LVM2/lib/locking/no_locking.c	2009/12/11 13:16:38	1.20
+++ LVM2/lib/locking/no_locking.c	2010/01/22 09:45:29	1.21
@@ -72,7 +72,7 @@
 	    (flags & LCK_SCOPE_MASK) == LCK_VG &&
 	    !(flags & LCK_CACHE) &&
 	    strcmp(resource, VG_GLOBAL)) {
-		log_error("Write locks are prohibited with --ignorelockingfailure.");
+		log_error("Write locks are prohibited with read-only locking.");
 		return 0;
 	}
 
--- LVM2/liblvm/lvm_base.c	2009/07/29 18:38:27	1.13
+++ LVM2/liblvm/lvm_base.c	2010/01/22 09:45:29	1.14
@@ -51,7 +51,6 @@
 	/* initialize locking */
 	if (!init_locking(-1, cmd)) {
 		/* FIXME: use EAGAIN as error code here */
-		log_error("Locking initialisation failed.");
 		lvm_quit((lvm_t) cmd);
 		return NULL;
 	}
--- LVM2/tools/lvmcmdline.c	2010/01/21 13:41:39	1.112
+++ LVM2/tools/lvmcmdline.c	2010/01/22 09:45:29	1.113
@@ -1027,8 +1027,6 @@
 		locking_type = -1;
 
 	if (!init_locking(locking_type, cmd)) {
-		log_error("Locking type %d initialisation failed.",
-			  locking_type);
 		ret = ECMD_FAILED;
 		goto out;
 	}


