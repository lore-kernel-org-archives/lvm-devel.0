From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 15 Jan 2010 18:48:25 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/functions.c
Message-ID: <20100115184825.22205.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-15 18:48:24

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: functions.c 

Log message:
	When moving the cluster log server into the LVM tree, the in memory
	bitmap tracking was switched from the e2fsprogs implementation to
	the device-mapper implementation (dm_bitset_t).  The latter has a
	leading uin32_t field designed to hold the number of bits that are
	being tracked.  The code was not properly handling this change in
	all places.  Specifically, when getting the bitmap to/from disk.
	
	Endian adjustments will likely need to be made on the accounting
	field as well, since bitmaps are passed between machines on
	start-up.
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1390&r2=1.1391
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2010/01/15 16:35:26	1.1390
+++ LVM2/WHATS_NEW	2010/01/15 18:48:24	1.1391
@@ -1,5 +1,6 @@
 Version 2.02.59 - 
 ===================================
+  Fix cluster log issues with in-memory bitmaps.
   Improve target type compatibility checking in _percent_run().
   Add 'target_status_compatible' method to 'struct segtype_handler'.
   Fix difference between CTR table built and expected for cluster log.
--- LVM2/daemons/cmirrord/functions.c	2010/01/15 16:03:19	1.10
+++ LVM2/daemons/cmirrord/functions.c	2010/01/15 18:48:24	1.11
@@ -134,11 +134,11 @@
 
 static int find_next_zero_bit(dm_bitset_t bs, int start)
 {
-	while (dm_bit(bs, start++))
-		if (start >= (int)bs[0])
+	for (; dm_bit(bs, start); start++)
+		if (start >= *bs)
 			return -1;
 
-	return start - 1;
+	return start;
 }
 
 static uint64_t count_bits32(dm_bitset_t bs)
@@ -260,7 +260,9 @@
 	/* Read disk bits into sync_bits */
 	bitset_size = lc->region_count / 8;
 	bitset_size += (lc->region_count % 8) ? 1 : 0;
-	memcpy(lc->clean_bits, lc->disk_buffer + 1024, bitset_size);
+
+	/* 'lc->clean_bits + 1' becasue dm_bitset_t leads with a uint32_t */
+	memcpy(lc->clean_bits + 1, lc->disk_buffer + 1024, bitset_size);
 
 	return 0;
 }
@@ -285,7 +287,9 @@
 	/* Write disk bits from clean_bits */
 	bitset_size = lc->region_count / 8;
 	bitset_size += (lc->region_count % 8) ? 1 : 0;
-	memcpy(lc->disk_buffer + 1024, lc->clean_bits, bitset_size);
+
+	/* 'lc->clean_bits + 1' becasue dm_bitset_t leads with a uint32_t */
+	memcpy(lc->disk_buffer + 1024, lc->clean_bits + 1, bitset_size);
 
 	if (rw_log(lc, 1)) {
 		lc->log_dev_failed = 1;
@@ -477,10 +481,11 @@
 		dm_bit_set_all(lc->sync_bits);
 
 	lc->sync_count = (sync == NOSYNC) ? region_count : 0;
+
 	if (disk_log) {
 		page_size = sysconf(_SC_PAGESIZE);
-		pages = ((int)lc->clean_bits[0])/page_size;
-		pages += ((int)lc->clean_bits[0])%page_size ? 1 : 0;
+		pages = *(lc->clean_bits) / page_size;
+		pages += *(lc->clean_bits) % page_size ? 1 : 0;
 		pages += 1; /* for header */
 
 		r = open(disk_path, O_RDWR | O_DIRECT);
@@ -1639,10 +1644,14 @@
 	return 0;
 }
 
-static void print_bits(char *buf, int size, int print)
+static void print_bits(dm_bitset_t bs, int print)
 {
-	int i;
+	int i, size;
 	char outbuf[128];
+	unsigned char *buf = bs + 1;
+
+	size = (*bs % 8) ? 1 : 0;
+	size += (*bs / 8);
 
 	memset(outbuf, 0, sizeof(outbuf));
 
@@ -1700,7 +1709,7 @@
 	}
 
 	/* Size in 'int's */
-	bitset_size = ((int)lc->clean_bits[0]/DM_BITS_PER_INT) + 1;
+	bitset_size = (*(lc->clean_bits) / DM_BITS_PER_INT) + 1;
 
 	/* Size in bytes */
 	bitset_size *= 4;
@@ -1714,14 +1723,18 @@
 
 	if (!strncmp(which, "sync_bits", 9)) {
 		memcpy(*buf, lc->sync_bits + 1, bitset_size);
+
 		LOG_DBG("[%s] storing sync_bits (sync_count = %llu):",
 			SHORT_UUID(uuid), (unsigned long long)
 			count_bits32(lc->sync_bits));
-		print_bits(*buf, bitset_size, 0);
+
+		print_bits(lc->sync_bits, 0);
 	} else if (!strncmp(which, "clean_bits", 9)) {
 		memcpy(*buf, lc->clean_bits + 1, bitset_size);
+
 		LOG_DBG("[%s] storing clean_bits:", SHORT_UUID(lc->uuid));
-		print_bits(*buf, bitset_size, 0);
+
+		print_bits(lc->clean_bits, 0);
 	}
 
 	return bitset_size;
@@ -1754,7 +1767,7 @@
 	}
 
 	/* Size in 'int's */
-	bitset_size = ((int)lc->clean_bits[0]/DM_BITS_PER_INT) + 1;
+	bitset_size = (*(lc->clean_bits) /DM_BITS_PER_INT) + 1;
 
 	/* Size in bytes */
 	bitset_size *= 4;
@@ -1768,15 +1781,19 @@
 	if (!strncmp(which, "sync_bits", 9)) {
 		lc->resume_override += 1;
 		memcpy(lc->sync_bits + 1, buf, bitset_size);
+
 		LOG_DBG("[%s] loading sync_bits (sync_count = %llu):",
 			SHORT_UUID(lc->uuid),(unsigned long long)
 			count_bits32(lc->sync_bits));
-		print_bits((char *)lc->sync_bits, bitset_size, 0);
+
+		print_bits(lc->sync_bits, 0);
 	} else if (!strncmp(which, "clean_bits", 9)) {
 		lc->resume_override += 2;
 		memcpy(lc->clean_bits + 1, buf, bitset_size);
+
 		LOG_DBG("[%s] loading clean_bits:", SHORT_UUID(lc->uuid));
-		print_bits((char *)lc->clean_bits, bitset_size, 0);
+
+		print_bits(lc->sync_bits, 0);
 	}
 
 	return 0;
@@ -1819,9 +1836,9 @@
 	dm_list_iterate_items(lc, &log_pending_list) {
 		LOG_ERROR("%s", lc->uuid);
 		LOG_ERROR("sync_bits:");
-		print_bits((char *)lc->sync_bits, (int)lc->sync_bits[0], 1);
+		print_bits(lc->sync_bits, 1);
 		LOG_ERROR("clean_bits:");
-		print_bits((char *)lc->clean_bits, (int)lc->sync_bits[0], 1);
+		print_bits(lc->clean_bits, 1);
 	}
 
 	dm_list_iterate_items(lc, &log_list) {
@@ -1832,9 +1849,9 @@
 		LOG_ERROR("  recovery_halted  : %s", (lc->recovery_halted) ?
 			  "YES" : "NO");
 		LOG_ERROR("sync_bits:");
-		print_bits((char *)lc->sync_bits, (int)lc->sync_bits[0], 1);
+		print_bits(lc->sync_bits, 1);
 		LOG_ERROR("clean_bits:");
-		print_bits((char *)lc->clean_bits, (int)lc->sync_bits[0], 1);
+		print_bits(lc->clean_bits, 1);
 
 		LOG_ERROR("Validating %s::", SHORT_UUID(lc->uuid));
 		r = find_next_zero_bit(lc->sync_bits, 0);


