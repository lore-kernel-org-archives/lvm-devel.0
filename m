From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 20 Aug 2013 18:22:34 +0000 (UTC)
Subject: master - cmirrord: Prevent secondary checkpoints from corrupting bitmaps
Message-ID: <20130820182234.13D5E611A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0be9ac9047a30bb2befe6a8d9130f466d37d9fd
Commit:        f0be9ac9047a30bb2befe6a8d9130f466d37d9fd
Parent:        99fd710cfd8beb88eb860e16007209d0acb1c440
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Aug 20 13:21:09 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Aug 20 13:21:09 2013 -0500

cmirrord: Prevent secondary checkpoints from corrupting bitmaps

The bug addressed by this patch manifested itself during testing
by showing a mirror that never became 'in-sync' after creation.
The bug is isolated to distributions that do not have support
for openAIS checkpointing (i.e. > RHEL6, > F16).

When a node joins a group that is managing a mirror log, the other
machines in the group send it a checkpoint representing the current
state of the bitmap.  More than one machine can send a checkpoint,
but only the initial one should be imported.  Once the bitmap state
has been imported from the initial checkpoint, operations (such
as resync, mark, and clear operations) can begin.  When subsequent
checkpoints are allowed to be imported, it has the effect of erasing
all the log operations between the initial checkpoint and the ones
that follow.

When cmirrord was updated to handle the absence of openAIS
checkpointing (commit 62e38da133d9801cdf36b0f2aaec615ce14b9000),
the new import_checkpoint() function failed to honor the 'no_read'
parameter.  This parameter was designed to avoid reading all but
the initial checkpoint.  Honoring this parameter has solved the
issue of corrupting bitmap data with secondary checkpoints.
---
 WHATS_NEW                  |    1 +
 daemons/cmirrord/cluster.c |   43 +++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3cf3e47..0d58e66 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Prevent cluster mirror logs from being corrupted by redundant checkpoints.
   Fix ignored lvmetad update on loop device configuration (2.02.99).
   Use LVM_PATH instead of hardcoded value in lvm2 activation systemd generator.
   Refresh existing VG before autoactivation (event retrigger/device reappeared).
diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index f19b2a9..fea739a 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -25,7 +25,6 @@
 #if CMIRROR_HAS_CHECKPOINT
 #include <openais/saAis.h>
 #include <openais/saCkpt.h>
-#endif
 
 /* Open AIS error codes */
 #define str_ais_error(x)						\
@@ -57,6 +56,40 @@
 	((x) == SA_AIS_ERR_TOO_BIG) ? "SA_AIS_ERR_TOO_BIG" :		\
 	((x) == SA_AIS_ERR_NO_SECTIONS) ? "SA_AIS_ERR_NO_SECTIONS" :	\
 	"ais_error_unknown"
+#else
+#define str_ais_error(x)						\
+	((x) == CS_OK) ? "CS_OK" :				\
+	((x) == CS_ERR_LIBRARY) ? "CS_ERR_LIBRARY" :		\
+	((x) == CS_ERR_VERSION) ? "CS_ERR_VERSION" :		\
+	((x) == CS_ERR_INIT) ? "CS_ERR_INIT" :			\
+	((x) == CS_ERR_TIMEOUT) ? "CS_ERR_TIMEOUT" :		\
+	((x) == CS_ERR_TRY_AGAIN) ? "CS_ERR_TRY_AGAIN" :	\
+	((x) == CS_ERR_INVALID_PARAM) ? "CS_ERR_INVALID_PARAM" : \
+	((x) == CS_ERR_NO_MEMORY) ? "CS_ERR_NO_MEMORY" :	\
+	((x) == CS_ERR_BAD_HANDLE) ? "CS_ERR_BAD_HANDLE" :	\
+	((x) == CS_ERR_BUSY) ? "CS_ERR_BUSY" :			\
+	((x) == CS_ERR_ACCESS) ? "CS_ERR_ACCESS" :		\
+	((x) == CS_ERR_NOT_EXIST) ? "CS_ERR_NOT_EXIST" :	\
+	((x) == CS_ERR_NAME_TOO_LONG) ? "CS_ERR_NAME_TOO_LONG" : \
+	((x) == CS_ERR_EXIST) ? "CS_ERR_EXIST" :		\
+	((x) == CS_ERR_NO_SPACE) ? "CS_ERR_NO_SPACE" :		\
+	((x) == CS_ERR_INTERRUPT) ? "CS_ERR_INTERRUPT" :	\
+	((x) == CS_ERR_NAME_NOT_FOUND) ? "CS_ERR_NAME_NOT_FOUND" : \
+	((x) == CS_ERR_NO_RESOURCES) ? "CS_ERR_NO_RESOURCES" :	\
+	((x) == CS_ERR_NOT_SUPPORTED) ? "CS_ERR_NOT_SUPPORTED" : \
+	((x) == CS_ERR_BAD_OPERATION) ? "CS_ERR_BAD_OPERATION" : \
+	((x) == CS_ERR_FAILED_OPERATION) ? "CS_ERR_FAILED_OPERATION" : \
+	((x) == CS_ERR_MESSAGE_ERROR) ? "CS_ERR_MESSAGE_ERROR" : \
+	((x) == CS_ERR_QUEUE_FULL) ? "CS_ERR_QUEUE_FULL" :	\
+	((x) == CS_ERR_QUEUE_NOT_AVAILABLE) ? "CS_ERR_QUEUE_NOT_AVAILABLE" : \
+	((x) == CS_ERR_BAD_FLAGS) ? "CS_ERR_BAD_FLAGS" :	\
+	((x) == CS_ERR_TOO_BIG) ? "CS_ERR_TOO_BIG" :		\
+	((x) == CS_ERR_NO_SECTIONS) ? "CS_ERR_NO_SECTIONS" :	\
+	((x) == CS_ERR_CONTEXT_NOT_FOUND) ? "CS_ERR_CONTEXT_NOT_FOUND" : \
+	((x) == CS_ERR_TOO_MANY_GROUPS) ? "CS_ERR_TOO_MANY_GROUPS" : \
+	((x) == CS_ERR_SECURITY) ? "CS_ERR_SECURITY" : \
+	"cs_error_unknown"
+#endif
 
 #define _RQ_TYPE(x)							\
 	((x) == DM_ULOG_CHECKPOINT_READY) ? "DM_ULOG_CHECKPOINT_READY": \
@@ -803,6 +836,11 @@ static int import_checkpoint(struct clog_cpg *entry, int no_read,
 {
 	int bitmap_size;
 
+	if (no_read) {
+		LOG_DBG("Checkpoint for this log already received");
+		return 0;
+	}
+
 	bitmap_size = (rq->u_rq.data_size - RECOVERING_REGION_SECTION_SIZE) / 2;
 	if (bitmap_size < 0) {
 		LOG_ERROR("Checkpoint has invalid payload size.");
@@ -947,7 +985,8 @@ static int do_cluster_work(void *data __attribute__((unused)))
 	dm_list_iterate_items_safe(entry, tmp, &clog_cpg_list) {
 		r = cpg_dispatch(entry->handle, CS_DISPATCH_ALL);
 		if (r != CS_OK)
-			LOG_ERROR("cpg_dispatch failed: %d", r);
+			LOG_ERROR("cpg_dispatch failed: %s",
+				  str_ais_error(r));
 
 		if (entry->free_me) {
 			free(entry);


