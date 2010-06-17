From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Jun 2010 12:48:57 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20100617124857.14730.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-17 12:48:55

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c clvmd-gulm.c clvmd-gulm.h 
	                 lvm-functions.c 
	lib/locking    : locking.h 

Log message:
	Clean up cluster lock mode and flags definition.
	
	Code is mixing up internal DLM and LVM definitions of lock
	modes and flags.
	
	OpenAIS and singlenode locking do not depend on DLM but
	code currently cannot be compiled without libdlm.h!
	
	LCK_* flags is LVM abstraction, used through all the code.
	Only low-level backend (clvmd-cman etc) should use DLM definitions,
	also this code should do all needed conversions.
	
	Because there are two DLM flags used in generic code
	(NOQUEUE, CONVERT) we define it similar way like lock modes.
	(So all needed binary-compatible flags are on one place in locking.h)
	
	(Further code cleaning still needed, though:-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1615&r2=1.1616
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2010/06/17 12:14:43	1.1615
+++ LVM2/WHATS_NEW	2010/06/17 12:48:54	1.1616
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Do not use internal DLM lock definitions in generic LVM2 clvmd code.
   Add dmeventd man page.
   Update lvresize/extend/reduce manpages with --nofsck, --resizefs options.
   Fix lvm2cmd example in documentation.
--- LVM2/daemons/clvmd/clvmd-command.c	2010/06/15 11:00:45	1.37
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/06/17 12:48:55	1.38
@@ -69,7 +69,6 @@
 #include <unistd.h>
 #include <errno.h>
 #include "libdevmapper.h"
-#include <libdlm.h>
 
 #include "locking.h"
 #include "lvm-logging.h"
@@ -239,7 +238,7 @@
 	/* Read locks need to be PR; other modes get passed through */
 	if (lock_mode == LCK_READ)
 	    lock_mode = LCK_PREAD;
-	status = sync_lock(lockname, lock_mode, (lock_cmd & LCK_NONBLOCK) ? LKF_NOQUEUE : 0, &lkid);
+	status = sync_lock(lockname, lock_mode, (lock_cmd & LCK_NONBLOCK) ? LCKF_NOQUEUE : 0, &lkid);
 	if (status)
 	    status = errno;
 	else
@@ -266,7 +265,7 @@
 
 	switch (header->cmd) {
 	case CLVMD_CMD_TEST:
-		status = sync_lock("CLVMD_TEST", LKM_EXMODE, 0, &lockid);
+		status = sync_lock("CLVMD_TEST", LCK_EXCL, 0, &lockid);
 		client->bits.localsock.private = (void *)(long)lockid;
 		break;
 
--- LVM2/daemons/clvmd/clvmd-gulm.c	2010/06/15 11:00:45	1.29
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2010/06/17 12:48:55	1.30
@@ -739,7 +739,7 @@
     pthread_mutex_lock(&lwait.mutex);
 
     /* This needs to be converted from DLM/LVM2 value for GULM */
-    if (flags & LKF_NOQUEUE) flags = lg_lock_flag_Try;
+    if (flags & LCKF_NOQUEUE) flags = lg_lock_flag_Try;
 
     dm_hash_insert(lock_hash, resource, &lwait);
     DEBUGLOG("lock_resource '%s', flags=%d, mode=%d\n", resource, flags, mode);
--- LVM2/daemons/clvmd/clvmd-gulm.h	2007/07/24 15:35:11	1.4
+++ LVM2/daemons/clvmd/clvmd-gulm.h	2010/06/17 12:48:55	1.5
@@ -1,7 +1,3 @@
-
-/* DLM constant that clvmd uses as a generic NONBLOCK lock flag */
-#define LKF_NOQUEUE 1
-
 extern int get_next_node_csid(void **context, char *csid);
 extern void add_down_node(char *csid);
 extern int gulm_fd(void);
--- LVM2/daemons/clvmd/lvm-functions.c	2010/06/15 11:00:45	1.92
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/06/17 12:48:55	1.93
@@ -35,7 +35,6 @@
 #include <syslog.h>
 #include <assert.h>
 #include "libdevmapper.h"
-#include <libdlm.h>
 
 #include "lvm-types.h"
 #include "clvm.h"
@@ -243,7 +242,7 @@
 	struct lv_info *lvi;
 
 	/* Mask off invalid options */
-	flags &= LKF_NOQUEUE | LKF_CONVERT;
+	flags &= LCKF_NOQUEUE | LCKF_CONVERT;
 
 	lvi = lookup_info(resource);
 
@@ -253,7 +252,7 @@
 	}
 
 	/* Only allow explicit conversions */
-	if (lvi && !(flags & LKF_CONVERT)) {
+	if (lvi && !(flags & LCKF_CONVERT)) {
 		errno = EBUSY;
 		return -1;
 	}
@@ -276,7 +275,7 @@
 			return -1;
 
 		lvi->lock_mode = mode;
-		status = sync_lock(resource, mode, flags & ~LKF_CONVERT, &lvi->lock_id);
+		status = sync_lock(resource, mode, flags & ~LCKF_CONVERT, &lvi->lock_id);
 		saved_errno = errno;
 		if (status) {
 			free(lvi);
@@ -346,9 +345,9 @@
 		return 0;	/* Success, we did nothing! */
 
 	/* Do we need to activate exclusively? */
-	if ((activate_lv == 2) || (mode == LKM_EXMODE)) {
+	if ((activate_lv == 2) || (mode == LCK_EXCL)) {
 		exclusive = 1;
-		mode = LKM_EXMODE;
+		mode = LCK_EXCL;
 	}
 
 	/*
@@ -357,7 +356,7 @@
 	 * of exclusive lock to shared one during activation.
 	 */
 	if (lock_flags & LCK_CLUSTER_VG) {
-		status = hold_lock(resource, mode, LKF_NOQUEUE | (lock_flags & LCK_CONVERT?LKF_CONVERT:0));
+		status = hold_lock(resource, mode, LCKF_NOQUEUE | (lock_flags & LCK_CONVERT ? LCKF_CONVERT:0));
 		if (status) {
 			/* Return an LVM-sensible error for this.
 			 * Forcing EIO makes the upper level return this text
@@ -465,12 +464,11 @@
 
 	mode = get_current_lock(resource);
 	switch (mode) {
-		case LKM_NLMODE: type = "NL"; break;
-		case LKM_CRMODE: type = "CR"; break;
-		case LKM_CWMODE: type = "CW"; break;
-		case LKM_PRMODE: type = "PR"; break;
-		case LKM_PWMODE: type = "PW"; break;
-		case LKM_EXMODE: type = "EX"; break;
+		case LCK_NULL: type = "NL"; break;
+		case LCK_READ: type = "CR"; break;
+		case LCK_PREAD:type = "PR"; break;
+		case LCK_WRITE:type = "PW"; break;
+		case LCK_EXCL: type = "EX"; break;
 	}
 
 	DEBUGLOG("do_lock_query: resource '%s', mode %i (%s)\n", resource, mode, type ?: "?");
@@ -511,7 +509,7 @@
 
 	switch (command & LCK_MASK) {
 	case LCK_LV_EXCLUSIVE:
-		status = do_activate_lv(resource, lock_flags, LKM_EXMODE);
+		status = do_activate_lv(resource, lock_flags, LCK_EXCL);
 		break;
 
 	case LCK_LV_SUSPEND:
@@ -528,7 +526,7 @@
 		break;
 
 	case LCK_LV_ACTIVATE:
-		status = do_activate_lv(resource, lock_flags, LKM_CRMODE);
+		status = do_activate_lv(resource, lock_flags, LCK_READ);
 		break;
 
 	case LCK_LV_DEACTIVATE:
@@ -560,14 +558,14 @@
 	/* Nearly all the stuff happens cluster-wide. Apart from SUSPEND. Here we get the
 	   lock out on this node (because we are the node modifying the metadata)
 	   before suspending cluster-wide.
-	   LKF_CONVERT is used always, local node is going to modify metadata
+	   LCKF_CONVERT is used always, local node is going to modify metadata
 	 */
 	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_SUSPEND &&
 	    (lock_flags & LCK_CLUSTER_VG)) {
 		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
-		if (hold_lock(resource, LKM_PWMODE, LKF_NOQUEUE | LKF_CONVERT))
+		if (hold_lock(resource, LCK_WRITE, LCKF_NOQUEUE | LCKF_CONVERT))
 			return errno;
 	}
 	return 0;
@@ -590,7 +588,7 @@
 
 		/* If the lock state is PW then restore it to what it was */
 		oldmode = get_current_lock(resource);
-		if (oldmode == LKM_PWMODE) {
+		if (oldmode == LCK_WRITE) {
 			struct lvinfo lvi;
 
 			pthread_mutex_lock(&lvm_lock);
@@ -600,7 +598,7 @@
 				return EIO;
 
 			if (lvi.exists) {
-				if (hold_lock(resource, LKM_CRMODE, LKF_CONVERT))
+				if (hold_lock(resource, LCK_READ, LCKF_CONVERT))
 					return errno;
 			} else {
 				if (hold_unlock(resource))
@@ -792,15 +790,15 @@
 				memcpy(&uuid[58], &lv[32], 6);
 				uuid[64] = '\0';
 
-				lock_mode = LKM_CRMODE;
+				lock_mode = LCK_READ;
 
 				/* Look for this lock in the list of EX locks
 				   we were passed on the command-line */
 				if (was_ex_lock(uuid, argv))
-					lock_mode = LKM_EXMODE;
+					lock_mode = LCK_EXCL;
 
 				DEBUGLOG("getting initial lock for %s\n", uuid);
-				hold_lock(uuid, lock_mode, LKF_NOQUEUE);
+				hold_lock(uuid, lock_mode, LCKF_NOQUEUE);
 			}
 		}
 	}
--- LVM2/lib/locking/locking.h	2010/05/21 14:29:49	1.56
+++ LVM2/lib/locking/locking.h	2010/06/17 12:48:55	1.57
@@ -73,6 +73,12 @@
 #define LCK_UNLOCK      0x00000006U	/* This is ours */
 
 /*
+ * Lock flags - these numbers are the same as DLM
+ */
+#define LCKF_NOQUEUE	0x00000001U	/* LKF$_NOQUEUE */
+#define LCKF_CONVERT	0x00000004U	/* LKF$_CONVERT */
+
+/*
  * Lock scope
  */
 #define LCK_SCOPE_MASK	0x00000008U


