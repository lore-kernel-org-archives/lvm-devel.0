From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Aug 2009 16:34:09 -0000
Subject: LVM2 ./Makefile.in ./configure.in daemons/Make ...
Message-ID: <20090813163409.21880.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-08-13 16:34:07

Modified files:
	.              : Makefile.in configure.in 
	daemons        : Makefile.in 
	daemons/clogd  : clogd.c cluster.c cluster.h common.h 
	                 functions.c functions.h link_mon.c link_mon.h 
	                 local.c local.h logging.c logging.h 

Log message:
	cluster log daemon (clogd): Add to LVM build system
	
	This check-in includes the touch-ups, make file changes, copyrights,
	and other necessities to include the cluster log daemon into the
	build system.
	
	[autoconf still needs to be run to generate the 'configure' and
	'Makefile' files.]

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/clogd.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/common.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/link_mon.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/link_mon.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/local.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/local.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/logging.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/logging.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/Makefile.in	2009/07/31 11:49:53	1.34
+++ LVM2/Makefile.in	2009/08/13 16:34:07	1.35
@@ -34,6 +34,7 @@
 
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS += daemons/clvmd \
+	     daemons/clogd \
 	     daemons/dmeventd/plugins \
 	     daemons/dmeventd \
 	     lib/format1 \
--- LVM2/configure.in	2009/07/31 13:31:53	1.105
+++ LVM2/configure.in	2009/08/13 16:34:07	1.106
@@ -63,7 +63,7 @@
 
 ################################################################################
 dnl -- Checks for programs.
-AC_PROG_SED
+m4_pattern_allow(AC_PROG_SED)
 AC_PROG_AWK
 AC_PROG_CC
 
@@ -72,7 +72,7 @@
 AC_PROG_INSTALL
 AC_PROG_LN_S
 AC_PROG_MAKE_SET
-AC_PROG_MKDIR_P
+m4_pattern_allow(AC_PROG_MKDIR_P)
 AC_PROG_RANLIB
 AC_PATH_PROG(CFLOW_CMD, cflow)
 AC_PATH_PROG(CSCOPE_CMD, cscope)
@@ -353,6 +353,23 @@
 fi
 
 ################################################################################
+dnl -- Build cluster log daemon
+AC_MSG_CHECKING(whether to build cluster log daemon)
+AC_ARG_ENABLE(clogd, [  --enable-clogd          Enable the cluster log daemon],
+CLOGD=$enableval)
+AC_MSG_RESULT($CLOGD)
+
+dnl -- Look for corosync libraries if required.
+if [[ "x$CLOGD" = xall -o `expr x"$CLOGD" : '.*corosync.*'` != 0 ]]; then
+#
+#       FIXME: ALSO NEED TO CHECK FOR CHECKPOINT MODULE
+#
+	PKG_CHECK_MODULES(CPG, libcpg, [],
+		[AC_MSG_RESULT([no pkg for libcpg library, using -lcpg]);
+		CPG_LIBS="-lcpg"])
+fi
+
+################################################################################
 dnl -- Enable debugging
 AC_MSG_CHECKING(whether to enable debugging)
 AC_ARG_ENABLE(debug,    [  --enable-debug          Enable debugging],
@@ -801,6 +818,7 @@
 AC_SUBST(CLDWHOLEARCHIVE)
 AC_SUBST(CLUSTER)
 AC_SUBST(CLVMD)
+AC_SUBST(CLOGD)
 AC_SUBST(CMDLIB)
 AC_SUBST(CONFDB_CFLAGS)
 AC_SUBST(CONFDB_LIBS)
@@ -870,6 +888,7 @@
 make.tmpl
 daemons/Makefile
 daemons/clvmd/Makefile
+daemons/clogd/Makefile
 daemons/dmeventd/Makefile
 daemons/dmeventd/libdevmapper-event.pc
 daemons/dmeventd/plugins/Makefile
--- LVM2/daemons/Makefile.in	2008/11/04 16:41:47	1.7
+++ LVM2/daemons/Makefile.in	2009/08/13 16:34:07	1.8
@@ -21,6 +21,10 @@
   SUBDIRS = clvmd
 endif
 
+ifeq ("@CLOGD@", "yes")
+  SUBDIRS += clogd
+endif
+
 ifeq ("@DMEVENTD@", "yes")
   SUBDIRS += dmeventd
 endif
--- LVM2/daemons/clogd/clogd.c	2009/07/21 15:34:53	1.3
+++ LVM2/daemons/clogd/clogd.c	2009/08/13 16:34:07	1.4
@@ -1,3 +1,14 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 #include <stdio.h>
 #include <stdlib.h>
 #include <stdint.h>
@@ -13,9 +24,9 @@
 #include <linux/types.h>
 #include <sys/socket.h>
 #include <linux/netlink.h>
-#include <linux/dm-log-userspace.h>
 #include <linux/dm-ioctl.h>
 
+#include "dm-log-userspace.h"
 #include "functions.h"
 #include "local.h"
 #include "cluster.h"
--- LVM2/daemons/clogd/cluster.c	2009/07/28 21:14:12	1.7
+++ LVM2/daemons/clogd/cluster.c	2009/08/13 16:34:07	1.8
@@ -1,3 +1,14 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 #include <errno.h>
 #include <string.h>
 #include <sys/types.h>
@@ -14,8 +25,8 @@
 #include <openais/cpg.h>
 #include <openais/saCkpt.h>
 
-#include "linux/dm-log-userspace.h"
-#include <libdevmapper.h>
+#include "dm-log-userspace.h"
+#include "libdevmapper.h"
 #include "functions.h"
 #include "local.h"
 #include "common.h"
@@ -133,7 +144,7 @@
 	int count=0;
 	int found;
 	struct iovec iov;
-	struct clog_cpg *entry, *tmp;
+	struct clog_cpg *entry;
 
 	dm_list_iterate_items(entry, &clog_cpg_list)
 		if (!strncmp(entry->name.value, rq->u_rq.uuid,
@@ -263,7 +274,7 @@
 				   struct clog_request *rq)
 {
 	int r = 0;
-	struct clog_request *orig_rq, *n;
+	struct clog_request *orig_rq;
 
 	/*
 	 * If I didn't send it, then I don't care about the response
@@ -317,7 +328,7 @@
 
 static struct clog_cpg *find_clog_cpg(cpg_handle_t handle)
 {
-	struct clog_cpg *match, *tmp;
+	struct clog_cpg *match;
 
 	dm_list_iterate_items(match, &clog_cpg_list)
 		if (match->handle == handle)
@@ -852,7 +863,7 @@
 static int do_cluster_work(void *data)
 {
 	int r = SA_AIS_OK;
-	struct clog_cpg *entry, *tmp;
+	struct clog_cpg *entry;
 
 	dm_list_iterate_items(entry, &clog_cpg_list) {
 		r = cpg_dispatch(entry->handle, CPG_DISPATCH_ALL);
@@ -930,7 +941,7 @@
 	int i_am_server;
 	int response = 0;
 	struct clog_request *rq = msg;
-	struct clog_request *tmp_rq, *n;
+	struct clog_request *tmp_rq;
 	struct clog_cpg *match;
 
 	match = find_clog_cpg(handle);
@@ -1363,7 +1374,7 @@
 				struct cpg_address *joined_list,
 				int joined_list_entries)
 {
-	struct clog_cpg *match, *tmp;
+	struct clog_cpg *match;
 	int found = 0;
 
 	dm_list_iterate_items(match, &clog_cpg_list)
@@ -1448,7 +1459,7 @@
 	int r;
 	int size;
 	struct clog_cpg *new = NULL;
-	struct clog_cpg *tmp, *tmp2;
+	struct clog_cpg *tmp;
 
 	dm_list_iterate_items(tmp, &clog_cpg_list)
 		if (!strncmp(tmp->name.value, uuid, CPG_MAX_NAME_LENGTH)) {
@@ -1603,8 +1614,8 @@
 void cluster_debug(void)
 {
 	struct checkpoint_data *cp;
-	struct clog_cpg *entry, *tmp;
-	struct clog_request *rq, *n;
+	struct clog_cpg *entry;
+	struct clog_request *rq;
 	int i;
 
 	LOG_ERROR("");
--- LVM2/daemons/clogd/cluster.h	2009/07/28 21:14:12	1.4
+++ LVM2/daemons/clogd/cluster.h	2009/08/13 16:34:07	1.5
@@ -1,8 +1,19 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 #ifndef __CLUSTER_LOG_CLUSTER_DOT_H__
 #define __CLUSTER_LOG_CLUSTER_DOT_H__
 
-#include <libdevmapper.h>
-#include <linux/dm-log-userspace.h>
+#include "libdevmapper.h"
+#include "dm-log-userspace.h"
 
 /*
  * There is other information in addition to what can
--- LVM2/daemons/clogd/common.h	2009/07/21 15:34:53	1.2
+++ LVM2/daemons/clogd/common.h	2009/08/13 16:34:07	1.3
@@ -1,3 +1,14 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 #ifndef __CLUSTER_LOG_COMMON_DOT_H__
 #define __CLUSTER_LOG_COMMON_DOT_H__
 
--- LVM2/daemons/clogd/functions.c	2009/08/13 16:31:01	1.7
+++ LVM2/daemons/clogd/functions.c	2009/08/13 16:34:07	1.8
@@ -1,3 +1,17 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
 #include <stdint.h>
 #include <errno.h>
 #include <string.h>
@@ -7,7 +21,7 @@
 #include <unistd.h>
 #include <signal.h>
 #include <linux/kdev_t.h>
-#define __USE_GNU /* for O_DIRECT */
+//#define __USE_GNU /* for O_DIRECT */
 #include <fcntl.h>
 #include <time.h>
 #include "libdevmapper.h"
@@ -54,7 +68,6 @@
 	uint32_t region_size;
 	uint32_t region_count;
 	uint64_t sync_count;
-	uint32_t bitset_uint32_count;
 
 	dm_bitset_t clean_bits;
 	dm_bitset_t sync_bits;
@@ -104,18 +117,18 @@
 
 static int log_test_bit(dm_bitset_t bs, int bit)
 {
-	return dm_bit(bs, i);
+	return dm_bit(bs, bit);
 }
 
 static void log_set_bit(struct log_c *lc, dm_bitset_t bs, int bit)
 {
-	dm_bit_set(bs, i);
+	dm_bit_set(bs, bit);
 	lc->touched = 1;
 }
 
 static void log_clear_bit(struct log_c *lc, dm_bitset_t bs, int bit)
 {
-	dm_bit_clear(bs, i);
+	dm_bit_clear(bs, bit);
 	lc->touched = 1;
 }
 
@@ -353,9 +366,8 @@
 	char *p;
 	uint64_t region_size;
 	uint64_t region_count;
-	uint32_t bitset_size;
 	struct log_c *lc = NULL;
-	struct log_c *dup;
+	struct log_c *duplicate;
 	enum sync sync = DEFAULTSYNC;
 	uint32_t block_on_error = 0;
 
@@ -438,8 +450,8 @@
 	strncpy(lc->uuid, uuid, DM_UUID_LEN);
 	lc->luid = luid;
 
-	if ((dup = get_log(lc->uuid, lc->luid)) ||
-	    (dup = get_pending_log(lc->uuid, lc->luid))) {
+	if ((duplicate = get_log(lc->uuid, lc->luid)) ||
+	    (duplicate = get_pending_log(lc->uuid, lc->luid))) {
 		LOG_ERROR("[%s/%llu] Log already exists, unable to create.",
 			  SHORT_UUID(lc->uuid), lc->luid);
 		free(lc);
@@ -448,33 +460,27 @@
 
 	dm_list_init(&lc->mark_list);
 
-	lc->bitset_uint32_count = region_count / 
-		(sizeof(*lc->clean_bits) << BYTE_SHIFT);
-	if (region_count % (sizeof(*lc->clean_bits) << BYTE_SHIFT))
-		lc->bitset_uint32_count++;
-
-	bitset_size = lc->bitset_uint32_count * sizeof(*lc->clean_bits);
-
-	lc->clean_bits = malloc(bitset_size);	
+	lc->clean_bits = dm_bitset_create(NULL, region_count);
 	if (!lc->clean_bits) {
 		LOG_ERROR("Unable to allocate clean bitset");
 		r = -ENOMEM;
 		goto fail;
 	}
-	memset(lc->clean_bits, -1, bitset_size);
 
-	lc->sync_bits = malloc(bitset_size);
+	lc->sync_bits = dm_bitset_create(NULL, region_count);
 	if (!lc->sync_bits) {
 		LOG_ERROR("Unable to allocate sync bitset");
 		r = -ENOMEM;
 		goto fail;
 	}
-	memset(lc->sync_bits, (sync == NOSYNC) ? -1 : 0, bitset_size);
+	if (sync == NOSYNC)
+		dm_bit_set_all(lc->sync_bits);
+
 	lc->sync_count = (sync == NOSYNC) ? region_count : 0;
 	if (disk_log) {
 		page_size = sysconf(_SC_PAGESIZE);
-		pages = bitset_size/page_size;
-		pages += bitset_size%page_size ? 1 : 0;
+		pages = ((int)lc->clean_bits[0])/page_size;
+		pages += ((int)lc->clean_bits[0])%page_size ? 1 : 0;
 		pages += 1; /* for header */
 
 		r = open(disk_path, O_RDWR | O_DIRECT);
@@ -709,7 +715,6 @@
 	uint32_t i;
 	int commit_log = 0;
 	struct log_c *lc = get_log(rq->uuid, rq->luid);
-	size_t size = lc->bitset_uint32_count * sizeof(uint32_t);
 
 	if (!lc)
 		return -EINVAL;
@@ -792,7 +797,7 @@
 		log_clear_bit(lc, lc->clean_bits, i);
 
 	/* copy clean across to sync */
-	memcpy(lc->sync_bits, lc->clean_bits, size);
+	dm_bit_copy(lc->sync_bits, lc->clean_bits);
 
 	if (commit_log && (lc->disk_fd >= 0)) {
 		rq->error = write_log(lc);
@@ -812,7 +817,7 @@
 		log_clear_bit(lc, lc->sync_bits, i);
 	}
 
-	lc->sync_count = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
+	lc->sync_count = count_bits32(lc->sync_bits);
 
 	LOG_SPRINT(lc, "[%s] Initial sync_count = %llu",
 		   SHORT_UUID(lc->uuid), (unsigned long long)lc->sync_count);
@@ -1218,7 +1223,6 @@
 	}
 
 	pkg->r = find_next_zero_bit(lc->sync_bits,
-				    lc->region_count,
 				    lc->sync_search);
 
 	if (pkg->r >= lc->region_count) {
@@ -1301,8 +1305,8 @@
 			   (unsigned long long)pkg->region);
 	}
 
-	if (lc->sync_count != count_bits32(lc->sync_bits, lc->bitset_uint32_count)) {
-		unsigned long long reset = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
+	if (lc->sync_count != count_bits32(lc->sync_bits)) {
+		unsigned long long reset = count_bits32(lc->sync_bits);
 
 		LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "sync_count(%llu) != bitmap count(%llu)",
@@ -1348,8 +1352,8 @@
 
 	rq->data_size = sizeof(*sync_count);
 
-	if (lc->sync_count != count_bits32(lc->sync_bits, lc->bitset_uint32_count)) {
-		unsigned long long reset = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
+	if (lc->sync_count != count_bits32(lc->sync_bits)) {
+		unsigned long long reset = count_bits32(lc->sync_bits);
 
 		LOG_SPRINT(lc, "get_sync_count - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "sync_count(%llu) != bitmap count(%llu)",
@@ -1689,11 +1693,16 @@
 			   SHORT_UUID(lc->uuid), debug_who,
 			   (unsigned long long)lc->recovering_region,
 			   lc->recoverer,
-			   (unsigned long long)count_bits32(lc->sync_bits, lc->bitset_uint32_count));
+			   (unsigned long long)count_bits32(lc->sync_bits));
 		return 64;
 	}
 
-	bitset_size = lc->bitset_uint32_count * sizeof(*lc->clean_bits);
+	/* Size in 'int's */
+	bitset_size = ((int)lc->clean_bits[0]/DM_BITS_PER_INT) + 1;
+
+	/* Size in bytes */
+	bitset_size *= 4;
+
 	*buf = malloc(bitset_size);
 
 	if (!*buf) {
@@ -1702,13 +1711,13 @@
 	}
 
 	if (!strncmp(which, "sync_bits", 9)) {
-		memcpy(*buf, lc->sync_bits, bitset_size);
+		memcpy(*buf, lc->sync_bits + 1, bitset_size);
 		LOG_DBG("[%s] storing sync_bits (sync_count = %llu):",
 			SHORT_UUID(uuid), (unsigned long long)
-			count_bits32(lc->sync_bits, lc->bitset_uint32_count));
+			count_bits32(lc->sync_bits));
 		print_bits(*buf, bitset_size, 0);
 	} else if (!strncmp(which, "clean_bits", 9)) {
-		memcpy(*buf, lc->clean_bits, bitset_size);
+		memcpy(*buf, lc->clean_bits + 1, bitset_size);
 		LOG_DBG("[%s] storing clean_bits:", SHORT_UUID(lc->uuid));
 		print_bits(*buf, bitset_size, 0);
 	}
@@ -1742,7 +1751,12 @@
 		return 0;
 	}
 
-	bitset_size = lc->bitset_uint32_count * sizeof(*lc->clean_bits);
+	/* Size in 'int's */
+	bitset_size = ((int)lc->clean_bits[0]/DM_BITS_PER_INT) + 1;
+
+	/* Size in bytes */
+	bitset_size *= 4;
+
 	if (bitset_size != size) {
 		LOG_ERROR("pull_state(%s): bad bitset_size (%d vs %d)",
 			  which, size, bitset_size);
@@ -1751,14 +1765,14 @@
 
 	if (!strncmp(which, "sync_bits", 9)) {
 		lc->resume_override += 1;
-		memcpy(lc->sync_bits, buf, bitset_size);
+		memcpy(lc->sync_bits + 1, buf, bitset_size);
 		LOG_DBG("[%s] loading sync_bits (sync_count = %llu):",
 			SHORT_UUID(lc->uuid),(unsigned long long)
-			count_bits32(lc->sync_bits, lc->bitset_uint32_count));
+			count_bits32(lc->sync_bits));
 		print_bits((char *)lc->sync_bits, bitset_size, 0);
 	} else if (!strncmp(which, "clean_bits", 9)) {
 		lc->resume_override += 2;
-		memcpy(lc->clean_bits, buf, bitset_size);
+		memcpy(lc->clean_bits + 1, buf, bitset_size);
 		LOG_DBG("[%s] loading clean_bits:", SHORT_UUID(lc->uuid));
 		print_bits((char *)lc->clean_bits, bitset_size, 0);
 	}
@@ -1803,11 +1817,9 @@
 	dm_list_iterate_items(lc, &log_pending_list) {
 		LOG_ERROR("%s", lc->uuid);
 		LOG_ERROR("sync_bits:");
-		print_bits((char *)lc->sync_bits,
-			   lc->bitset_uint32_count * sizeof(*lc->sync_bits), 1);
+		print_bits((char *)lc->sync_bits, (int)lc->sync_bits[0], 1);
 		LOG_ERROR("clean_bits:");
-		print_bits((char *)lc->clean_bits,
-			   lc->bitset_uint32_count * sizeof(*lc->clean_bits), 1);
+		print_bits((char *)lc->clean_bits, (int)lc->sync_bits[0], 1);
 	}
 
 	dm_list_iterate_items(lc, &log_list) {
@@ -1818,14 +1830,12 @@
 		LOG_ERROR("  recovery_halted  : %s", (lc->recovery_halted) ?
 			  "YES" : "NO");
 		LOG_ERROR("sync_bits:");
-		print_bits((char *)lc->sync_bits,
-			   lc->bitset_uint32_count * sizeof(*lc->sync_bits), 1);
+		print_bits((char *)lc->sync_bits, (int)lc->sync_bits[0], 1);
 		LOG_ERROR("clean_bits:");
-		print_bits((char *)lc->clean_bits,
-			   lc->bitset_uint32_count * sizeof(*lc->clean_bits), 1);
+		print_bits((char *)lc->clean_bits, (int)lc->sync_bits[0], 1);
 
 		LOG_ERROR("Validating %s::", SHORT_UUID(lc->uuid));
-		r = find_next_zero_bit(lc->sync_bits, lc->region_count, 0);
+		r = find_next_zero_bit(lc->sync_bits, 0);
 		LOG_ERROR("  lc->region_count = %llu",
 			  (unsigned long long)lc->region_count);
 		LOG_ERROR("  lc->sync_count = %llu",
--- LVM2/daemons/clogd/functions.h	2009/07/28 15:55:50	1.4
+++ LVM2/daemons/clogd/functions.h	2009/08/13 16:34:07	1.5
@@ -1,7 +1,18 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 #ifndef __CLOG_FUNCTIONS_DOT_H__
 #define __CLOG_FUNCTIONS_DOT_H__
 
-#include <linux/dm-log-userspace.h>
+#include "dm-log-userspace.h"
 #include "cluster.h"
 
 #define LOG_RESUMED   1
--- LVM2/daemons/clogd/link_mon.c	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/link_mon.c	2009/08/13 16:34:07	1.2
@@ -1,3 +1,14 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 #include <stdlib.h>
 #include <errno.h>
 #include <poll.h>
--- LVM2/daemons/clogd/link_mon.h	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/link_mon.h	2009/08/13 16:34:07	1.2
@@ -1,3 +1,14 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 #ifndef __LINK_MON_DOT_H__
 #define __LINK_MON_DOT_H__
 
--- LVM2/daemons/clogd/local.c	2009/07/21 15:34:53	1.3
+++ LVM2/daemons/clogd/local.c	2009/08/13 16:34:07	1.4
@@ -1,3 +1,14 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 #include <unistd.h>
 #include <errno.h>
 #include <string.h>
@@ -8,7 +19,7 @@
 #include <linux/connector.h>
 #include <linux/netlink.h>
 
-#include "linux/dm-log-userspace.h"
+#include "dm-log-userspace.h"
 #include "functions.h"
 #include "cluster.h"
 #include "common.h"
@@ -16,6 +27,12 @@
 #include "link_mon.h"
 #include "local.h"
 
+#ifndef CN_IDX_DM
+#warning Kernel should be at least 2.6.31
+#define CN_IDX_DM                       0x7     /* Device Mapper */
+#define CN_VAL_DM_USERSPACE_LOG         0x1
+#endif
+
 static int cn_fd;  /* Connector (netlink) socket fd */
 static char recv_buf[2048];
 static char send_buf[2048];
--- LVM2/daemons/clogd/local.h	2009/07/21 15:34:53	1.2
+++ LVM2/daemons/clogd/local.h	2009/08/13 16:34:07	1.3
@@ -1,3 +1,14 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 #ifndef __CLUSTER_LOG_LOCAL_DOT_H__
 #define __CLUSTER_LOG_LOCAL_DOT_H__
 
--- LVM2/daemons/clogd/logging.c	2009/07/21 15:34:53	1.2
+++ LVM2/daemons/clogd/logging.c	2009/08/13 16:34:07	1.3
@@ -1,3 +1,14 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 #include <stdio.h>
 #include <syslog.h>
 
--- LVM2/daemons/clogd/logging.h	2009/07/28 21:14:12	1.3
+++ LVM2/daemons/clogd/logging.h	2009/08/13 16:34:07	1.4
@@ -1,3 +1,15 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
 #ifndef __CLUSTER_LOG_LOGGING_DOT_H__
 #define __CLUSTER_LOG_LOGGING_DOT_H__
 


