From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:58:39 -0000
Subject: LVM2/daemons/cmirrord functions.c
Message-ID: <20101220135839.18301.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:58:39

Modified files:
	daemons/cmirrord: functions.c 

Log message:
	Removed unused pointer
	
	Pointer 'duplicate' is unused.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/daemons/cmirrord/functions.c	2010/12/20 13:57:19	1.26
+++ LVM2/daemons/cmirrord/functions.c	2010/12/20 13:58:38	1.27
@@ -366,7 +366,6 @@
 	uint64_t region_size;
 	uint64_t region_count;
 	struct log_c *lc = NULL;
-	struct log_c *duplicate;
 	enum sync log_sync = DEFAULTSYNC;
 	uint32_t block_on_error = 0;
 
@@ -448,8 +447,8 @@
 	strncpy(lc->uuid, uuid, DM_UUID_LEN);
 	lc->luid = luid;
 
-	if ((duplicate = get_log(lc->uuid, lc->luid)) ||
-	    (duplicate = get_pending_log(lc->uuid, lc->luid))) {
+	if (get_log(lc->uuid, lc->luid) ||
+	    get_pending_log(lc->uuid, lc->luid)) {
 		LOG_ERROR("[%s/%" PRIu64 "u] Log already exists, unable to create.",
 			  SHORT_UUID(lc->uuid), lc->luid);
 		dm_free(lc);


