From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 17 Aug 2010 23:56:25 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/functions.c
Message-ID: <20100817235625.9805.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-08-17 23:56:24

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: functions.c 

Log message:
	Fix for bug 596453: multiple mirror image failures cause lvm repair...
	
	The lvm repair issues I believe are the superficial symptoms of this
	bug - there are worse issues that are not as clearly seen.  From my
	inline comments:
	* If the mirror was successfully recovered, we want to always
	* force every machine to write to all devices - otherwise,
	* corruption will occur.  Here's how:
	*    Node1 suffers a failure and marks a region out-of-sync
	*    Node2 attempts a write, gets by is_remote_recovering,
	*          and queries the sync status of the region - finding
	*          it out-of-sync.
	*    Node2 thinks the write should be a nosync write, but it
	*          hasn't suffered the drive failure that Node1 has yet.
	*          It then issues a generic_make_request directly to
	*          the primary image only - which is exactly the device
	*          that has suffered the failure.
	*    Node2 suffers a lost write - which completely bypasses the
	*          mirror layer because it had gone through generic_m_r.
	*    The file system will likely explode at this point due to
	*    I/O errors.  If it wasn't the primary that failed, it is
	*    easily possible in this case to issue writes to just one
	*    of the remaining images - also leaving the mirror inconsistent.
	*
	* We let in_sync() return 1 in a cluster regardless of what is
	* in the bitmap once recovery has successfully completed on a
	* mirror.  This ensures the mirroring code will continue to
	* attempt to write to all mirror images.  The worst that can
	* happen for reads is that additional read attempts may be
	* taken.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1709&r2=1.1710
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2010/08/17 19:25:05	1.1709
+++ LVM2/WHATS_NEW	2010/08/17 23:56:23	1.1710
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix potential for corruption during cluster mirror device failure.
   Use 'SINGLENODE' instead of 'dead' in clvmd singlenode messages.
   Ignore snapshots when performing mirror recovery beneath an origin.
   Pass LCK_ORIGIN_ONLY flag around cluster.
--- LVM2/daemons/cmirrord/functions.c	2010/08/04 18:18:18	1.22
+++ LVM2/daemons/cmirrord/functions.c	2010/08/17 23:56:24	1.23
@@ -54,6 +54,7 @@
 
 	time_t delay; /* limits how fast a resume can happen after suspend */
 	int touched;
+	int in_sync;  /* An in-sync that stays set until suspend/resume */
 	uint32_t region_size;
 	uint32_t region_count;
 	uint64_t sync_count;
@@ -720,6 +721,7 @@
 	if (!lc)
 		return -EINVAL;
 
+	lc->in_sync = 0;
 	switch (lc->resume_override) {
 	case 1000:
 		LOG_ERROR("[%s] Additional resume issued before suspend",
@@ -963,6 +965,42 @@
 		return -EINVAL;
 
 	*rtn = log_test_bit(lc->sync_bits, region);
+
+	/*
+	 * If the mirror was successfully recovered, we want to always
+	 * force every machine to write to all devices - otherwise,
+	 * corruption will occur.  Here's how:
+	 *    Node1 suffers a failure and marks a region out-of-sync
+	 *    Node2 attempts a write, gets by is_remote_recovering,
+   	 *          and queries the sync status of the region - finding
+	 *	    it out-of-sync.
+	 *    Node2 thinks the write should be a nosync write, but it
+	 *          hasn't suffered the drive failure that Node1 has yet.
+	 *          It then issues a generic_make_request directly to
+	 *          the primary image only - which is exactly the device
+	 *          that has suffered the failure.
+	 *    Node2 suffers a lost write - which completely bypasses the
+	 *          mirror layer because it had gone through generic_m_r.
+	 *    The file system will likely explode at this point due to
+	 *    I/O errors.  If it wasn't the primary that failed, it is
+	 *    easily possible in this case to issue writes to just one
+	 *    of the remaining images - also leaving the mirror inconsistent.
+	 *
+	 * We let in_sync() return 1 in a cluster regardless of what is
+	 * in the bitmap once recovery has successfully completed on a
+	 * mirror.  This ensures the mirroring code will continue to
+	 * attempt to write to all mirror images.  The worst that can
+	 * happen for reads is that additional read attempts may be
+	 * taken.
+	 *
+	 * Futher investigation may be required to determine if there are
+	 * similar possible outcomes when the mirror is in the process of
+	 * recovering.  In that case, lc->in_sync would not have been set
+	 * yet.
+	 */
+	if (!*rtn && lc->in_sync)
+		*rtn = 1;
+
 	if (*rtn)
 		LOG_DBG("[%s] Region is in-sync: %llu",
 			SHORT_UUID(lc->uuid), (unsigned long long)region);
@@ -1282,7 +1320,7 @@
 				lc->skip_bit_warning = lc->region_count;
 
 			if (pkg->region > (lc->skip_bit_warning + 5)) {
-				LOG_ERROR("*** Region #%llu skipped during recovery ***",
+				LOG_SPRINT(lc, "*** Region #%llu skipped during recovery ***",
 					  (unsigned long long)lc->skip_bit_warning);
 				lc->skip_bit_warning = lc->region_count;
 #ifdef DEBUG
@@ -1324,6 +1362,9 @@
 			   "(lc->sync_count > lc->region_count) - this is bad",
 			   rq->seq, SHORT_UUID(lc->uuid), originator);
 
+	if (lc->sync_count == lc->region_count)
+		lc->in_sync = 1;
+
 	rq->data_size = 0;
 	return 0;
 }


