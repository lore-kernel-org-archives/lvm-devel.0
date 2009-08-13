From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Aug 2009 16:31:03 -0000
Subject: LVM2 daemons/clogd/functions.c include/.symlin ...
Message-ID: <20090813163103.30196.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-08-13 16:31:02

Modified files:
	daemons/clogd  : functions.c 
	include        : .symlinks 
	libdm          : libdm-deptree.c 

Log message:
	Cluster log daemon (clogd): use LVM bitops in place of ext2 bitops
	
	Eliminate dependency on outside library, since the same functionality
	exists in our tree.
	
	[It is important that the bitops work in the same way, as the bitmaps
	must remain backwards compatible.  I haven't tested every architecture,
	but the x86* archs work.  My test involved using the old ext2fsprogs
	bitops, memcpy'ing the bits over to the LVM bitset array and ensuring
	that only the bits set via the old methods were set.]

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/daemons/clogd/functions.c	2009/07/28 21:14:12	1.6
+++ LVM2/daemons/clogd/functions.c	2009/08/13 16:31:01	1.7
@@ -6,13 +6,12 @@
 #include <dirent.h>
 #include <unistd.h>
 #include <signal.h>
-#include <ext2fs/ext2_fs.h>
-#include <ext2fs/ext2fs.h>
 #include <linux/kdev_t.h>
 #define __USE_GNU /* for O_DIRECT */
 #include <fcntl.h>
 #include <time.h>
-#include "linux/dm-log-userspace.h"
+#include "libdevmapper.h"
+#include "dm-log-userspace.h"
 #include "functions.h"
 #include "common.h"
 #include "cluster.h"
@@ -57,8 +56,8 @@
 	uint64_t sync_count;
 	uint32_t bitset_uint32_count;
 
-	uint32_t *clean_bits;
-	uint32_t *sync_bits;
+	dm_bitset_t clean_bits;
+	dm_bitset_t sync_bits;
 	uint32_t recoverer;
 	uint64_t recovering_region; /* -1 means not recovering */
 	uint64_t skip_bit_warning; /* used to warn if region skipped */
@@ -103,43 +102,41 @@
 static DM_LIST_INIT(log_list);
 static DM_LIST_INIT(log_pending_list);
 
-static int log_test_bit(uint32_t *bs, unsigned bit)
+static int log_test_bit(dm_bitset_t bs, int bit)
 {
-	return ext2fs_test_bit(bit, (unsigned int *) bs) ? 1 : 0;
+	return dm_bit(bs, i);
 }
 
-static void log_set_bit(struct log_c *lc, uint32_t *bs, unsigned bit)
+static void log_set_bit(struct log_c *lc, dm_bitset_t bs, int bit)
 {
-	ext2fs_set_bit(bit, (unsigned int *) bs);
+	dm_bit_set(bs, i);
 	lc->touched = 1;
 }
 
-static void log_clear_bit(struct log_c *lc, uint32_t *bs, unsigned bit)
+static void log_clear_bit(struct log_c *lc, dm_bitset_t bs, int bit)
 {
-	ext2fs_clear_bit(bit, (unsigned int *) bs);
+	dm_bit_clear(bs, i);
 	lc->touched = 1;
 }
 
-/* FIXME: Why aren't count and start the same type? */
-static uint64_t find_next_zero_bit(uint32_t *bits, uint32_t count, int start)
+static int find_next_zero_bit(dm_bitset_t bs, int start)
 {
-	for(; (start < count) && log_test_bit(bits, start); start++);
-	return start;
+	while (dm_bit(bs, start++))
+		if (start >= (int)bs[0])
+			return -1;
+
+	return start - 1;
 }
 
-static uint64_t count_bits32(uint32_t *addr, uint32_t count)
+static uint64_t count_bits32(dm_bitset_t bs)
 {
-	int j;
-	uint32_t i;
-	uint64_t rtn = 0;
+	int i, size = ((int)bs[0]/DM_BITS_PER_INT + 1);
+	unsigned count = 0;
 
-	for (i = 0; i < count; i++) {
-		if (!addr[i])
-			continue;
-		for (j = 0; j < 32; j++)
-			rtn += (addr[i] & (1<<j)) ? 1 : 0;
-	}
-	return rtn;
+	for (i = 1; i <= size; i++)
+		count += hweight32(bs[i]);
+
+	return (uint64_t)count;
 }
 
 /*
--- LVM2/include/.symlinks	2009/07/29 13:26:01	1.59
+++ LVM2/include/.symlinks	2009/08/13 16:31:01	1.60
@@ -55,6 +55,7 @@
 ../libdm/libdevmapper.h
 ../libdm/misc/dm-ioctl.h
 ../libdm/misc/dm-logging.h
+../libdm/misc/dm-log-userspace.h
 ../libdm/misc/dmlib.h
 ../libdm/misc/kdev_t.h
 ../po/pogen.h
--- LVM2/libdm/libdm-deptree.c	2009/08/03 18:01:47	1.55
+++ LVM2/libdm/libdm-deptree.c	2009/08/13 16:31:01	1.56
@@ -20,6 +20,7 @@
 
 #include <stdarg.h>
 #include <sys/param.h>
+#include <sys/utsname.h>
 
 #define MAX_TARGET_PARAMSIZE 500000
 
@@ -1278,65 +1279,144 @@
 	return 1;
 }
 
-static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
-			      uint32_t minor, struct load_segment *seg,
-			      uint64_t *seg_start, char *params,
-			      size_t paramsize)
+static int mirror_emit_segment_line(struct dm_task *dmt, uint32_t major,
+				    uint32_t minor, struct load_segment *seg,
+				    uint64_t *seg_start, char *params,
+				    size_t paramsize)
 {
+	int r;
+	int block_on_error = 0;
+	int handle_errors = 0;
+	int dm_log_userspace = 0;
+	struct utsname uts;
 	unsigned log_parm_count;
 	int pos = 0;
-	int r;
-	char originbuf[DM_FORMAT_DEV_BUFSIZE], cowbuf[DM_FORMAT_DEV_BUFSIZE];
 	char logbuf[DM_FORMAT_DEV_BUFSIZE];
 	const char *logtype;
 
-	switch(seg->type) {
-	case SEG_ERROR:
-	case SEG_ZERO:
-	case SEG_LINEAR:
-		break;
-	case SEG_MIRRORED:
-		log_parm_count = 1;	/* Region size */
-		log_parm_count += hweight32(seg->flags);	/* [no]sync, block_on_error etc. */
+	r = uname(&uts);
+	if (r)
+		return_0;
+
+	if ((seg->flags & DM_BLOCK_ON_ERROR)) {
+		/*
+		 * Originally, block_on_error was an argument to the log
+		 * portion of the mirror CTR table.  It was renamed to
+		 * "handle_errors" and now resides in the 'features'
+		 * section of the mirror CTR table (i.e. at the end).
+		 *
+		 * We can identify whether to use "block_on_error" or
+		 * "handle_errors" by the dm-mirror module's version
+		 * number (>= 1.12) or by the kernel version (>= 2.6.22).
+		 */
+		if (strncmp(uts.release, "2.6.22", 6) >= 0)
+			handle_errors = 1;
+		else
+			block_on_error = 1;
+	}
+
+	if (seg->clustered) {
+		/* Cluster mirrors require a UUID */
+		if (!seg->uuid)
+			return_0;
+
+		/*
+		 * Cluster mirrors used to have their own log
+		 * types.  Now they are accessed through the
+		 * userspace log type.
+		 *
+		 * The dm-log-userspace module was added to the
+		 * 2.6.31 kernel.
+		 */
+		if (strncmp(uts.release, "2.6.31", 6) >= 0)
+			dm_log_userspace = 1;
+	}
+
+	/* Region size */
+	log_parm_count = 1;
+
+	/* [no]sync, block_on_error etc. */
+	log_parm_count += hweight32(seg->flags);
+
+	/* "handle_errors" is a feature arg now */
+	if (handle_errors)
+		log_parm_count--;
+
+	/* DM_CORELOG does not count in the param list */
+	if (seg->flags & DM_CORELOG)
+		log_parm_count--;
 
-		if (seg->flags & DM_CORELOG)
-			log_parm_count--;   /* DM_CORELOG does not count in the param list */
+	if (seg->clustered) {
+		log_parm_count++; /* For UUID */
 
-		if (seg->clustered) {
-			if (seg->uuid)
-				log_parm_count++;
+		if (!dm_log_userspace)
 			EMIT_PARAMS(pos, "clustered-");
-		}
+	}
 
-		if (!seg->log)
-			logtype = "core";
-		else {
-			logtype = "disk";
-			log_parm_count++;
-			if (!_build_dev_string(logbuf, sizeof(logbuf), seg->log))
-				return_0;
-		}
+	if (!seg->log)
+		logtype = "core";
+	else {
+		logtype = "disk";
+		log_parm_count++;
+		if (!_build_dev_string(logbuf, sizeof(logbuf), seg->log))
+			return_0;
+	}
 
+	if (dm_log_userspace)
+		EMIT_PARAMS(pos, "userspace %u %s clustered-%s",
+			    log_parm_count, seg->uuid, logtype);
+	else
 		EMIT_PARAMS(pos, "%s %u", logtype, log_parm_count);
 
-		if (seg->log)
-			EMIT_PARAMS(pos, " %s", logbuf);
+	if (seg->log)
+		EMIT_PARAMS(pos, " %s", logbuf);
 
-		EMIT_PARAMS(pos, " %u", seg->region_size);
+	EMIT_PARAMS(pos, " %u", seg->region_size);
 
-		if (seg->clustered && seg->uuid)
-			EMIT_PARAMS(pos, " %s", seg->uuid);
+	if (seg->clustered && !dm_log_userspace)
+		EMIT_PARAMS(pos, " %s", seg->uuid);
 
-		if ((seg->flags & DM_NOSYNC))
-			EMIT_PARAMS(pos, " nosync");
-		else if ((seg->flags & DM_FORCESYNC))
-			EMIT_PARAMS(pos, " sync");
+	if ((seg->flags & DM_NOSYNC))
+		EMIT_PARAMS(pos, " nosync");
+	else if ((seg->flags & DM_FORCESYNC))
+		EMIT_PARAMS(pos, " sync");
 
-		if ((seg->flags & DM_BLOCK_ON_ERROR))
-			EMIT_PARAMS(pos, " block_on_error");
+	if (block_on_error)
+		EMIT_PARAMS(pos, " block_on_error");
 
-		EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
+	EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
 
+	if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0) {
+		stack;
+		return r;
+	}
+
+	if (handle_errors)
+		EMIT_PARAMS(pos, " 1 handle_errors");
+
+	return 0;
+}
+
+static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
+			      uint32_t minor, struct load_segment *seg,
+			      uint64_t *seg_start, char *params,
+			      size_t paramsize)
+{
+	int pos = 0;
+	int r;
+	char originbuf[DM_FORMAT_DEV_BUFSIZE], cowbuf[DM_FORMAT_DEV_BUFSIZE];
+
+	switch(seg->type) {
+	case SEG_ERROR:
+	case SEG_ZERO:
+	case SEG_LINEAR:
+		break;
+	case SEG_MIRRORED:
+		/* Mirrors are pretty complicated - now in separate function */
+		r = mirror_emit_segment_line(dmt, major, minor, seg, seg_start,
+					     params, paramsize);
+		if (r)
+			return r;
 		break;
 	case SEG_SNAPSHOT:
 		if (!_build_dev_string(originbuf, sizeof(originbuf), seg->origin))
@@ -1371,7 +1451,6 @@
 		break;
 	case SEG_CRYPT:
 	case SEG_LINEAR:
-	case SEG_MIRRORED:
 	case SEG_STRIPED:
 		if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0) {
 			stack;


