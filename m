From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Jan 2010 20:08:45 -0000
Subject: LVM2/daemons/cmirrord clogd.c cluster.c compat ...
Message-ID: <20100118200845.22988.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-18 20:08:44

Modified files:
	daemons/cmirrord: clogd.c cluster.c compat.c functions.c 
	                  link_mon.c link_mon.h local.c logging.c 

Log message:
	Misc compilation clean-ups.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/compat.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/link_mon.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/link_mon.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/local.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/logging.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/daemons/cmirrord/clogd.c	2009/09/14 22:57:46	1.6
+++ LVM2/daemons/cmirrord/clogd.c	2010/01/18 20:08:44	1.7
@@ -46,7 +46,7 @@
 static void init_all(void);
 static void cleanup_all(void);
 
-int main(int argc, char *argv[])
+int main(int argc __attribute((unused)), char *argv[] __attribute((unused)))
 {
 	daemonize();
 
@@ -74,7 +74,7 @@
  * @sig: the signal
  *
  */
-static void parent_exit_handler(int sig)
+static void parent_exit_handler(int sig __attribute((unused)))
 {
 	exit_now = 1;
 }
@@ -85,7 +85,7 @@
  *
  * Returns: 0 on success, -1 otherwise
  */
-static int create_lockfile(char *lockfile)
+static int create_lockfile(const char *lockfile)
 {
 	int fd;
 	struct flock lock;
--- LVM2/daemons/cmirrord/cluster.c	2010/01/15 19:49:36	1.10
+++ LVM2/daemons/cmirrord/cluster.c	2010/01/18 20:08:44	1.11
@@ -227,7 +227,7 @@
 }
 
 static char rq_buffer[DM_ULOG_REQUEST_SIZE];
-static int handle_cluster_request(struct clog_cpg *entry,
+static int handle_cluster_request(struct clog_cpg *entry __attribute((unused)),
 				  struct clog_request *rq, int server)
 {
 	int r = 0;
@@ -867,7 +867,7 @@
 	return r;
 }
 
-static int do_cluster_work(void *data)
+static int do_cluster_work(void *data __attribute((unused)))
 {
 	int r = SA_AIS_OK;
 	struct clog_cpg *entry;
@@ -939,8 +939,8 @@
 	return 0;
 }
 
-static void cpg_message_callback(cpg_handle_t handle, const struct cpg_name *gname,
-				 uint32_t nodeid, uint32_t pid,
+static void cpg_message_callback(cpg_handle_t handle, const struct cpg_name *gname __attribute((unused)),
+				 uint32_t nodeid, uint32_t pid __attribute((unused)),
 				 void *msg, size_t msg_len)
 {
 	int i;
@@ -1377,7 +1377,7 @@
 	}
 }
 
-static void cpg_config_callback(cpg_handle_t handle, const struct cpg_name *gname,
+static void cpg_config_callback(cpg_handle_t handle, const struct cpg_name *gname __attribute((unused)),
 				const struct cpg_address *member_list,
 				size_t member_list_entries,
 				const struct cpg_address *left_list,
@@ -1422,7 +1422,7 @@
  *
  * Returns: 1 if checkpoint removed, 0 if no checkpoints, -EXXX on error
  */
-int remove_checkpoint(struct clog_cpg *entry)
+static int remove_checkpoint(struct clog_cpg *entry)
 {
 	int len;
 	SaNameT name;
--- LVM2/daemons/cmirrord/compat.c	2010/01/15 19:49:36	1.1
+++ LVM2/daemons/cmirrord/compat.c	2010/01/18 20:08:44	1.2
@@ -25,7 +25,7 @@
  */
 #define COMPAT_OFFSET 256
 
-static void v5_data_endian_switch(struct clog_request *rq, int to_network)
+static void v5_data_endian_switch(struct clog_request *rq, int to_network __attribute((unused)))
 {
 	int i, end;
 	int64_t *pi64;
@@ -201,7 +201,7 @@
 		if (data_len < (COMPAT_OFFSET + sizeof(*rq)))
 			return -ENOSPC;
 
-		rq = data + COMPAT_OFFSET;
+		rq = (char *)data + COMPAT_OFFSET;
 		break;
 	default:
 		LOG_ERROR("Unable to process cluster message: "
--- LVM2/daemons/cmirrord/functions.c	2010/01/15 18:48:24	1.11
+++ LVM2/daemons/cmirrord/functions.c	2010/01/18 20:08:44	1.12
@@ -262,7 +262,7 @@
 	bitset_size += (lc->region_count % 8) ? 1 : 0;
 
 	/* 'lc->clean_bits + 1' becasue dm_bitset_t leads with a uint32_t */
-	memcpy(lc->clean_bits + 1, lc->disk_buffer + 1024, bitset_size);
+	memcpy(lc->clean_bits + 1, (char *)lc->disk_buffer + 1024, bitset_size);
 
 	return 0;
 }
@@ -289,7 +289,7 @@
 	bitset_size += (lc->region_count % 8) ? 1 : 0;
 
 	/* 'lc->clean_bits + 1' becasue dm_bitset_t leads with a uint32_t */
-	memcpy(lc->disk_buffer + 1024, lc->clean_bits + 1, bitset_size);
+	memcpy((char *)lc->disk_buffer + 1024, lc->clean_bits + 1, bitset_size);
 
 	if (rw_log(lc, 1)) {
 		lc->log_dev_failed = 1;
@@ -372,7 +372,7 @@
 	uint64_t region_count;
 	struct log_c *lc = NULL;
 	struct log_c *duplicate;
-	enum sync sync = DEFAULTSYNC;
+	enum sync log_sync = DEFAULTSYNC;
 	uint32_t block_on_error = 0;
 
 	int disk_log = 0;
@@ -427,9 +427,9 @@
 
 	for (i = 0; i < argc; i++) {
 		if (!strcmp(argv[i], "sync"))
-			sync = FORCESYNC;
+			log_sync = FORCESYNC;
 		else if (!strcmp(argv[i], "nosync"))
-			sync = NOSYNC;
+			log_sync = NOSYNC;
 		else if (!strcmp(argv[i], "block_on_error"))
 			block_on_error = 1;
 	}
@@ -444,7 +444,7 @@
 
 	lc->region_size = region_size;
 	lc->region_count = region_count;
-	lc->sync = sync;
+	lc->sync = log_sync;
 	lc->block_on_error = block_on_error;
 	lc->sync_search = 0;
 	lc->recovering_region = (uint64_t)-1;
@@ -456,7 +456,7 @@
 
 	if ((duplicate = get_log(lc->uuid, lc->luid)) ||
 	    (duplicate = get_pending_log(lc->uuid, lc->luid))) {
-		LOG_ERROR("[%s/%llu] Log already exists, unable to create.",
+		LOG_ERROR("[%s/%" PRIu64 "u] Log already exists, unable to create.",
 			  SHORT_UUID(lc->uuid), lc->luid);
 		free(lc);
 		return -EINVAL;
@@ -477,10 +477,10 @@
 		r = -ENOMEM;
 		goto fail;
 	}
-	if (sync == NOSYNC)
+	if (log_sync == NOSYNC)
 		dm_bit_set_all(lc->sync_bits);
 
-	lc->sync_count = (sync == NOSYNC) ? region_count : 0;
+	lc->sync_count = (log_sync == NOSYNC) ? region_count : 0;
 
 	if (disk_log) {
 		page_size = sysconf(_SC_PAGESIZE);
@@ -1375,7 +1375,7 @@
 	return 0;
 }
 
-static int core_status_info(struct log_c *lc, struct dm_ulog_request *rq)
+static int core_status_info(struct log_c *lc __attribute((unused)), struct dm_ulog_request *rq)
 {
 	char *data = (char *)rq->data;
 
@@ -1648,7 +1648,7 @@
 {
 	int i, size;
 	char outbuf[128];
-	unsigned char *buf = bs + 1;
+	unsigned char *buf = (unsigned char *)(bs + 1);
 
 	size = (*bs % 8) ? 1 : 0;
 	size += (*bs / 8);
--- LVM2/daemons/cmirrord/link_mon.c	2009/08/13 16:34:07	1.2
+++ LVM2/daemons/cmirrord/link_mon.c	2010/01/18 20:08:44	1.3
@@ -14,10 +14,11 @@
 #include <poll.h>
 
 #include "logging.h"
+#include "link_mon.h"
 
 struct link_callback {
 	int fd;
-	char *name;
+	const char *name;
 	void *data;
 	int (*callback)(void *data);
 
@@ -29,7 +30,7 @@
 static struct pollfd *pfds = NULL;
 static struct link_callback *callbacks = NULL;
 
-int links_register(int fd, char *name, int (*callback)(void *data), void *data)
+int links_register(int fd, const char *name, int (*callback)(void *data), void *data)
 {
 	int i;
 	struct link_callback *lc;
--- LVM2/daemons/cmirrord/link_mon.h	2009/08/13 16:34:07	1.2
+++ LVM2/daemons/cmirrord/link_mon.h	2010/01/18 20:08:44	1.3
@@ -12,7 +12,7 @@
 #ifndef __LINK_MON_DOT_H__
 #define __LINK_MON_DOT_H__
 
-int links_register(int fd, char *name, int (*callback)(void *data), void *data);
+int links_register(int fd, const char *name, int (*callback)(void *data), void *data);
 int links_unregister(int fd);
 int links_monitor(void);
 int links_issue_callbacks(void);
--- LVM2/daemons/cmirrord/local.c	2009/08/13 16:34:07	1.4
+++ LVM2/daemons/cmirrord/local.c	2010/01/18 20:08:44	1.5
@@ -28,7 +28,7 @@
 #include "local.h"
 
 #ifndef CN_IDX_DM
-#warning Kernel should be at least 2.6.31
+/* Kernel 2.6.31 is required to run this code */
 #define CN_IDX_DM                       0x7     /* Device Mapper */
 #define CN_VAL_DM_USERSPACE_LOG         0x1
 #endif
@@ -159,12 +159,12 @@
 		 * once... perhaps at compile time?
 		 */
 //		*rq = container_of(u_rq, struct clog_request, u_rq);
-		*rq = (void *)u_rq -
+		*rq = (char *)u_rq -
 			(sizeof(struct clog_request) -
 			 sizeof(struct dm_ulog_request));
 
 		/* Clear the wrapper container fields */
-		memset(*rq, 0, (void *)u_rq - (void *)(*rq));
+		memset(*rq, 0, (char *)u_rq - (char *)(*rq));
 		break;
 	default:
 		LOG_ERROR("Unknown nlmsg_type");
@@ -218,7 +218,7 @@
  *
  * Returns: 0 on success, -EXXX on failure
  */
-static int do_local_work(void *data)
+static int do_local_work(void *data __attribute((unused)))
 {
 	int r;
 	struct clog_request *rq;
--- LVM2/daemons/cmirrord/logging.c	2009/08/13 16:34:07	1.3
+++ LVM2/daemons/cmirrord/logging.c	2010/01/18 20:08:44	1.4
@@ -12,7 +12,7 @@
 #include <stdio.h>
 #include <syslog.h>
 
-char *__rq_types_off_by_one[] = {
+const char *__rq_types_off_by_one[] = {
 	"DM_ULOG_CTR",
 	"DM_ULOG_DTR",
 	"DM_ULOG_PRESUSPEND",


