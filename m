From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:57:20 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/functions.c
Message-ID: <20101220135720.17858.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:57:19

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: functions.c 

Log message:
	Use dm_free for dm_malloc-ed areas in _clog_ctr/_clog_dtr (cmirrord).
	
	Use dm_zalloc to obtain zeroed memory block.
	Use dm_free for dm_ allocated memory blocks.
	Test close() for error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1845&r2=1.1846
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/WHATS_NEW	2010/12/20 13:53:10	1.1845
+++ LVM2/WHATS_NEW	2010/12/20 13:57:19	1.1846
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Use dm_free for dm_malloc-ed areas in _clog_ctr/_clog_dtr (cmirrord).
   Add checks for allocation errors in config node clonning.
   Fix error path if regex engine cannot be created in _build_matcher().
   Use char* arithmetic in target_version(), _process_all(), _targets().
--- LVM2/daemons/cmirrord/functions.c	2010/10/26 10:14:41	1.25
+++ LVM2/daemons/cmirrord/functions.c	2010/12/20 13:57:19	1.26
@@ -429,13 +429,12 @@
 			block_on_error = 1;
 	}
 
-	lc = malloc(sizeof(*lc));
+	lc = dm_zalloc(sizeof(*lc));
 	if (!lc) {
 		LOG_ERROR("Unable to allocate cluster log context");
 		r = -ENOMEM;
 		goto fail;
 	}
-	memset(lc, 0, sizeof(*lc));
 
 	lc->region_size = region_size;
 	lc->region_count = region_count;
@@ -453,7 +452,7 @@
 	    (duplicate = get_pending_log(lc->uuid, lc->luid))) {
 		LOG_ERROR("[%s/%" PRIu64 "u] Log already exists, unable to create.",
 			  SHORT_UUID(lc->uuid), lc->luid);
-		free(lc);
+		dm_free(lc);
 		return -EINVAL;
 	}
 
@@ -511,15 +510,13 @@
 	return 0;
 fail:
 	if (lc) {
-		if (lc->clean_bits)
-			free(lc->clean_bits);
-		if (lc->sync_bits)
-			free(lc->sync_bits);
-		if (lc->disk_buffer)
-			free(lc->disk_buffer);
-		if (lc->disk_fd >= 0)
-			close(lc->disk_fd);
-		free(lc);
+		if (lc->disk_fd >= 0 && close(lc->disk_fd))
+			LOG_ERROR("Close device error, %s: %s",
+				  disk_path, strerror(errno));
+		free(lc->disk_buffer);
+		dm_free(lc->sync_bits);
+		dm_free(lc->clean_bits);
+		dm_free(lc);
 	}
 	return r;
 }
@@ -634,9 +631,9 @@
 		close(lc->disk_fd);
 	if (lc->disk_buffer)
 		free(lc->disk_buffer);
-	free(lc->clean_bits);
-	free(lc->sync_bits);
-	free(lc);
+	dm_free(lc->clean_bits);
+	dm_free(lc->sync_bits);
+	dm_free(lc);
 
 	return 0;
 }


