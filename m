From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 1 Oct 2009 14:14:18 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20091001141418.8108.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-10-01 14:14:18

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Stop clvmd from automatically doing lock conversions. Now, if a lock
	is granted at one mode and an attempt to convert it wthout the LCK_CONVERT
	flag set then it will return errno=EBUSY.
	
	This fixes a pretty bad bug in which an LV could be activated exclusively on
	one node and lvchange -ay on another would convert it to shared!
	
	It might break some things in other areas, but I doubt it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1285&r2=1.1286
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2009/10/01 00:35:29	1.1285
+++ LVM2/WHATS_NEW	2009/10/01 14:14:17	1.1286
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Only do lock conversions in clvmd if we are explicitly asked for one.
   Introduce percent_range_t and centralise snapshot full/mirror in-sync checks.
   Factor out poll_mirror_progress and introduce progress_t.
   Distinguish between powers of 1000 and powers of 1024 in unit suffixes.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/08/05 14:18:35	1.68
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/10/01 14:14:17	1.69
@@ -143,10 +143,11 @@
 {
 	static char buf[128];
 
-	sprintf(buf, "0x%x (%s%s%s)", flags,
+	sprintf(buf, "0x%x (%s%s%s%s)", flags,
 		flags & LCK_PARTIAL_MODE	  ? "PARTIAL_MODE " : "",
 		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC " : "",
-		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR " : "");
+		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR " : "",
+		flags & LCK_CONVERT ? "CONVERT " : "");
 
 	return buf;
 }
@@ -239,13 +240,20 @@
 	int saved_errno;
 	struct lv_info *lvi;
 
-	flags &= LKF_NOQUEUE;	/* Only LKF_NOQUEUE is valid here */
+	/* Mask off invalid options */
+	flags &= LKF_NOQUEUE | LKF_CONVERT;
 
-	if ((lvi = lookup_info(resource))) {
+	lvi = lookup_info(resource);
+
+	/* Only allow explicit conversions */
+	if (lvi && !(flags & LKF_CONVERT)) {
+		errno = EBUSY;
+		return -1;
+	}
+	if (lvi) {
 		/* Already exists - convert it */
 		status =
-		    sync_lock(resource, mode, LKF_CONVERT | flags,
-			      &lvi->lock_id);
+		    sync_lock(resource, mode, flags, &lvi->lock_id);
 		saved_errno = errno;
 		if (!status)
 			lvi->lock_mode = mode;
@@ -337,7 +345,7 @@
 
 	/* Try to get the lock if it's a clustered volume group */
 	if (lock_flags & LCK_CLUSTER_VG) {
-		status = hold_lock(resource, mode, LKF_NOQUEUE);
+		status = hold_lock(resource, mode, LKF_NOQUEUE | (lock_flags & LCK_CONVERT?LKF_CONVERT:0));
 		if (status) {
 			/* Return an LVM-sensible error for this.
 			 * Forcing EIO makes the upper level return this text
@@ -538,7 +546,7 @@
 		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
-		if (hold_lock(resource, LKM_PWMODE, LKF_NOQUEUE))
+		if (hold_lock(resource, LKM_PWMODE, LKF_NOQUEUE| (lock_flags & LCK_CONVERT?LKF_CONVERT:0)))
 			return errno;
 	}
 	return 0;
@@ -570,7 +578,7 @@
 				return EIO;
 
 			if (lvi.exists) {
-				if (hold_lock(resource, LKM_CRMODE, 0))
+				if (hold_lock(resource, LKM_CRMODE, lock_flags & LCK_CONVERT?LKF_CONVERT:0))
 					return errno;
 			} else {
 				if (hold_unlock(resource))


