From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Jan 2010 17:24:30 -0000
Subject: LVM2/daemons/cmirrord functions.c
Message-ID: <20100119172430.6692.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-19 17:24:30

Modified files:
	daemons/cmirrord: functions.c 

Log message:
	remove more compiler warnings
	add FIXMEs for incomplete write()s

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/daemons/cmirrord/functions.c	2010/01/18 21:07:24	1.14
+++ LVM2/daemons/cmirrord/functions.c	2010/01/19 17:24:29	1.15
@@ -121,18 +121,18 @@
 	lc->touched = 1;
 }
 
-static int find_next_zero_bit(dm_bitset_t bs, int start)
+static uint64_t find_next_zero_bit(dm_bitset_t bs, unsigned start)
 {
 	for (; dm_bit(bs, start); start++)
 		if (start >= *bs)
-			return -1;
+			return (uint64_t)-1;
 
 	return start;
 }
 
 static uint64_t count_bits32(dm_bitset_t bs)
 {
-	int i, size = ((int)bs[0]/DM_BITS_PER_INT + 1);
+	unsigned i, size = bs[0]/(unsigned)DM_BITS_PER_INT + 1;
 	unsigned count = 0;
 
 	for (i = 1; i <= size; i++)
@@ -192,7 +192,7 @@
 {
 	int r;
 
-	r = lseek(lc->disk_fd, 0, SEEK_SET);
+	r = (int)lseek(lc->disk_fd, 0, SEEK_SET);
 	if (r < 0) {
 		LOG_ERROR("[%s] rw_log:  lseek failure: %s",
 			  SHORT_UUID(lc->uuid), strerror(errno));
@@ -200,6 +200,7 @@
 	}
 
 	if (do_write) {
+		/* FIXME Cope with full set of non-error conditions */
 		r = write(lc->disk_fd, lc->disk_buffer, lc->disk_size);
 		if (r < 0) {
 			LOG_ERROR("[%s] rw_log:  write failure: %s",
@@ -210,6 +211,7 @@
 	}
 
 	/* Read */
+	/* FIXME Cope with full set of non-error conditions */
 	r = read(lc->disk_fd, lc->disk_buffer, lc->disk_size);
 	if (r < 0)
 		LOG_ERROR("[%s] rw_log:  read failure: %s",
@@ -1219,8 +1221,7 @@
 		}
 	}
 
-	pkg->r = find_next_zero_bit(lc->sync_bits,
-				    lc->sync_search);
+	pkg->r = find_next_zero_bit(lc->sync_bits, lc->sync_search);
 
 	if (pkg->r >= lc->region_count) {
 		LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
@@ -1796,9 +1797,10 @@
 
 	lc = get_log(rq->uuid, rq->luid);
 	if (!lc)
+		/* FIXME Callers are ignoring this */
 		return -EINVAL;
 
-	return lc->state;
+	return (int)lc->state;
 }
 
 /*
@@ -1834,9 +1836,8 @@
 
 	dm_list_iterate_items(lc, &log_list) {
 		LOG_ERROR("%s", lc->uuid);
-		LOG_ERROR("  recoverer        : %u", lc->recoverer);
-		LOG_ERROR("  recovering_region: %llu",
-			  (unsigned long long)lc->recovering_region);
+		LOG_ERROR("  recoverer        : %" PRIu32, lc->recoverer);
+		LOG_ERROR("  recovering_region: %" PRIu64, lc->recovering_region);
 		LOG_ERROR("  recovery_halted  : %s", (lc->recovery_halted) ?
 			  "YES" : "NO");
 		LOG_ERROR("sync_bits:");
@@ -1846,12 +1847,9 @@
 
 		LOG_ERROR("Validating %s::", SHORT_UUID(lc->uuid));
 		r = find_next_zero_bit(lc->sync_bits, 0);
-		LOG_ERROR("  lc->region_count = %llu",
-			  (unsigned long long)lc->region_count);
-		LOG_ERROR("  lc->sync_count = %llu",
-			  (unsigned long long)lc->sync_count);
-		LOG_ERROR("  next zero bit  = %llu",
-			  (unsigned long long)r);
+		LOG_ERROR("  lc->region_count = %" PRIu32, lc->region_count);
+		LOG_ERROR("  lc->sync_count = %" PRIu64, lc->sync_count);
+		LOG_ERROR("  next zero bit  = %" PRIu64, r);
 		if ((r > lc->region_count) ||
 		    ((r == lc->region_count) && (lc->sync_count > lc->region_count))) {
 			LOG_ERROR("ADJUSTING SYNC_COUNT");


