From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Jan 2010 02:43:20 -0000
Subject: LVM2/daemons/cmirrord cluster.c cluster.h func ...
Message-ID: <20100120024320.21489.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-20 02:43:19

Modified files:
	daemons/cmirrord: cluster.c cluster.h functions.c 

Log message:
	Deal with a few more compiler warnings.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/daemons/cmirrord/cluster.c	2010/01/18 21:07:24	1.12
+++ LVM2/daemons/cmirrord/cluster.c	2010/01/20 02:43:19	1.13
@@ -436,9 +436,9 @@
 
 	len = snprintf((char *)(name.value), SA_MAX_NAME_LENGTH,
 		       "bitmaps_%s_%u", SHORT_UUID(cp->uuid), cp->requester);
-	name.length = len;
+	name.length = (SaUint16T)len;
 
-	len = strlen(cp->recovering_region) + 1;
+	len = (int)strlen(cp->recovering_region) + 1;
 
 	attr.creationFlags = SA_CKPT_WR_ALL_REPLICAS;
 	attr.checkpointSize = cp->bitmap_size * 2 + len;
@@ -476,7 +476,7 @@
 	/*
 	 * Add section for sync_bits
 	 */
-	section_id.idLen = snprintf(buf, 32, "sync_bits");
+	section_id.idLen = (SaUint16T)snprintf(buf, 32, "sync_bits");
 	section_id.id = (unsigned char *)buf;
 	section_attr.sectionId = &section_id;
 	section_attr.expirationTime = SA_TIME_END;
@@ -605,7 +605,7 @@
 
 	len = snprintf((char *)(name.value), SA_MAX_NAME_LENGTH, "bitmaps_%s_%u",
 		       SHORT_UUID(entry->name.value), my_cluster_id);
-	name.length = len;
+	name.length = (SaUint16T)len;
 
 open_retry:
 	rv = saCkptCheckpointOpen(ckpt_handle, &name, NULL,
@@ -1157,8 +1157,8 @@
 			      const struct cpg_address *member_list,
 			      size_t member_list_entries)
 {
-	int i;
-	int my_pid = getpid();
+	unsigned i;
+	uint32_t my_pid = (uint32_t)getpid();
 	uint32_t lowest = match->lowest_id;
 	struct clog_request *rq;
 	char dbuf[32];
@@ -1178,7 +1178,7 @@
 		goto out;
 
 	memset(dbuf, 0, sizeof(dbuf));
-	for (i = 0; i < (member_list_entries-1); i++)
+	for (i = 0; i < member_list_entries - 1; i++)
 		sprintf(dbuf+strlen(dbuf), "%u-", member_list[i].nodeid);
 	sprintf(dbuf+strlen(dbuf), "(%u)", joined->nodeid);
 	LOG_COND(log_checkpoint, "[%s] Joining node, %u needs checkpoint [%s]",
@@ -1236,7 +1236,8 @@
 			       const struct cpg_address *member_list,
 			       size_t member_list_entries)
 {
-	int i, j, fd;
+	unsigned i;
+	int j, fd;
 	uint32_t lowest = match->lowest_id;
 	struct clog_request *rq, *n;
 	struct checkpoint_data *p_cp, *c_cp;
@@ -1456,7 +1457,7 @@
 int create_cluster_cpg(char *uuid, uint64_t luid)
 {
 	int r;
-	int size;
+	size_t size;
 	struct clog_cpg *new = NULL;
 	struct clog_cpg *tmp;
 
@@ -1480,7 +1481,7 @@
 	size = ((strlen(uuid) + 1) > CPG_MAX_NAME_LENGTH) ?
 		CPG_MAX_NAME_LENGTH : (strlen(uuid) + 1);
 	strncpy(new->name.value, uuid, size);
-	new->name.length = size;
+	new->name.length = (uint32_t)size;
 	new->luid = luid;
 
 	/*
--- LVM2/daemons/cmirrord/cluster.h	2010/01/18 21:07:24	1.7
+++ LVM2/daemons/cmirrord/cluster.h	2010/01/20 02:43:19	1.8
@@ -15,7 +15,7 @@
 #include "dm-log-userspace.h"
 #include "libdevmapper.h"
 
-#define DM_ULOG_RESPONSE 0x1000 /* in last byte of 32-bit value */
+#define DM_ULOG_RESPONSE 0x1000U /* in last byte of 32-bit value */
 #define DM_ULOG_CHECKPOINT_READY 21
 #define DM_ULOG_MEMBER_JOIN      22
 
--- LVM2/daemons/cmirrord/functions.c	2010/01/19 18:21:03	1.16
+++ LVM2/daemons/cmirrord/functions.c	2010/01/20 02:43:19	1.17
@@ -290,7 +290,7 @@
 }
 
 /* FIXME Rewrite this function taking advantage of the udev changes (where in use) to improve its efficiency! */
-static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_path)
+static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_path __attribute((unused)))
 {
 	int r;
 	DIR *dp;


