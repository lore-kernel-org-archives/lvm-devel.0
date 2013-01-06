From: dongmao zhang <dmzhang@suse.com>
Date: Sun,  6 Jan 2013 16:46:35 +0800
Subject: [PATCH 1/2] Change cmirrord to multi-thread
In-Reply-To: <1357461996-368-1-git-send-email-dmzhang@suse.com>
References: <1357461996-368-1-git-send-email-dmzhang@suse.com>
Message-ID: <1357461996-368-2-git-send-email-dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: dongmao zhang <deanraccoon@gmail.com>

As https://bugzilla.redhat.com/show_bug.cgi?id=612221#c11 said,
when using mirrored log in cluster environment, a multi-threaded
cmirrord is needed.
The main thread(do_local_work) is used to receive netlink packet from kernel.
Once a new mirrored device created, new thread(cluster_thread_fn) is
created to handle request from cluster.
---
 daemons/cmirrord/cluster.c   |   94 +++++++++++++++++++++++++++--------------
 daemons/cmirrord/functions.c |    6 +-
 daemons/cmirrord/local.c     |    3 +-
 3 files changed, 67 insertions(+), 36 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 70c76c3..58a1f3f 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -22,6 +22,7 @@
 #include <errno.h>
 #include <signal.h>
 #include <unistd.h>
+#include <pthread.h>
 #if CMIRROR_HAS_CHECKPOINT
 #include <openais/saAis.h>
 #include <openais/saCkpt.h>
@@ -118,9 +119,11 @@ struct clog_cpg {
 	struct checkpoint_data *checkpoint_list;
 	int idx;
 	char debugging[DEBUGGING_HISTORY][128];
+	pthread_t thread_pid;
 };
 
 static struct dm_list clog_cpg_list;
+static pthread_rwlock_t clog_cpg_lock =PTHREAD_RWLOCK_INITIALIZER;
 
 /*
  * cluster_send
@@ -135,12 +138,14 @@ int cluster_send(struct clog_request *rq)
 	struct iovec iov;
 	struct clog_cpg *entry;
 
+	pthread_rwlock_rdlock(&clog_cpg_lock);
 	dm_list_iterate_items(entry, &clog_cpg_list)
 		if (!strncmp(entry->name.value, rq->u_rq.uuid,
 			     CPG_MAX_NAME_LENGTH)) {
 			found = 1;
 			break;
 		}
+	pthread_rwlock_unlock(&clog_cpg_lock);
 
 	if (!found) {
 		rq->u_rq.error = -ENOENT;
@@ -221,11 +226,11 @@ static struct clog_request *get_matching_rq(struct clog_request *rq,
 	return NULL;
 }
 
-static char rq_buffer[DM_ULOG_REQUEST_SIZE];
 static int handle_cluster_request(struct clog_cpg *entry __attribute__((unused)),
 				  struct clog_request *rq, int server)
 {
 	int r = 0;
+	char rq_buffer[DM_ULOG_REQUEST_SIZE];
 	struct clog_request *tmp = (struct clog_request *)rq_buffer;
 
 	/*
@@ -332,9 +337,13 @@ static struct clog_cpg *find_clog_cpg(cpg_handle_t handle)
 {
 	struct clog_cpg *match;
 
+	pthread_rwlock_rdlock(&clog_cpg_lock);
 	dm_list_iterate_items(match, &clog_cpg_list)
-		if (match->handle == handle)
+		if (match->handle == handle) {
+			pthread_rwlock_unlock(&clog_cpg_lock);
 			return match;
+		}
+	pthread_rwlock_unlock(&clog_cpg_lock);
 
 	return NULL;
 }
@@ -939,28 +948,17 @@ static int resend_requests(struct clog_cpg *entry)
 	return r;
 }
 
-static int do_cluster_work(void *data __attribute__((unused)))
+static void cluster_thread_fn(void *data)
 {
 	int r = CS_OK;
-	struct clog_cpg *entry, *tmp;
-
-	dm_list_iterate_items_safe(entry, tmp, &clog_cpg_list) {
-		r = cpg_dispatch(entry->handle, CS_DISPATCH_ALL);
-		if (r != CS_OK)
-			LOG_ERROR("cpg_dispatch failed: %d", r);
-
-		if (entry->free_me) {
-			free(entry);
-			continue;
-		}
-		do_checkpoints(entry, 0);
-
-		resend_requests(entry);
-	}
+	struct clog_cpg * match = data;
+	r = cpg_dispatch (match->handle, CS_DISPATCH_BLOCKING);
+	if (r != CS_OK)
+		LOG_DBG("cpg_dispatch failed");
 
-	return (r == CS_OK) ? 0 : -1;  /* FIXME: good error number? */
 }
 
+
 static int flush_startup_list(struct clog_cpg *entry)
 {
 	int r = 0;
@@ -1011,23 +1009,35 @@ static int flush_startup_list(struct clog_cpg *entry)
 	return 0;
 }
 
+static void do_cpg_message_callback(struct clog_cpg * match , uint32_t nodeid, void *msg, size_t msg_len);
+
 static void cpg_message_callback(cpg_handle_t handle, const struct cpg_name *gname __attribute__((unused)),
 				 uint32_t nodeid, uint32_t pid __attribute__((unused)),
 				 void *msg, size_t msg_len)
 {
+  struct clog_cpg * entry;
+
+	entry = find_clog_cpg(handle);
+	if (!entry) {
+		LOG_ERROR("Unable to find clog_cpg for cluster message");
+		return;
+	}
+	do_cpg_message_callback(entry, nodeid, msg, msg_len);
+
+	do_checkpoints(entry, 0);
+	resend_requests(entry);
+
+}
+
+static void do_cpg_message_callback(struct clog_cpg * match , uint32_t nodeid, void *msg, size_t msg_len)
+{
 	int i;
 	int r = 0;
 	int i_am_server;
 	int response = 0;
 	struct clog_request *rq = msg;
 	struct clog_request *tmp_rq;
-	struct clog_cpg *match;
 
-	match = find_clog_cpg(handle);
-	if (!match) {
-		LOG_ERROR("Unable to find clog_cpg for cluster message");
-		return;
-	}
 
 	/*
 	 * Perform necessary endian and version compatibility conversions
@@ -1324,7 +1334,7 @@ static void cpg_leave_callback(struct clog_cpg *match,
 			       size_t member_list_entries)
 {
 	unsigned i;
-	int j, fd;
+	int j;
 	uint32_t lowest = match->lowest_id;
 	struct clog_request *rq, *n;
 	struct checkpoint_data *p_cp, *c_cp;
@@ -1335,10 +1345,9 @@ static void cpg_leave_callback(struct clog_cpg *match,
 	/* Am I leaving? */
 	if (my_cluster_id == left->nodeid) {
 		LOG_DBG("Finalizing leave...");
+		pthread_rwlock_wrlock(&clog_cpg_lock);
 		dm_list_del(&match->list);
-
-		cpg_fd_get(match->handle, &fd);
-		links_unregister(fd);
+		pthread_rwlock_unlock(&clog_cpg_lock);
 
 		cluster_postsuspend(match->name.value, match->luid);
 
@@ -1466,11 +1475,13 @@ static void cpg_config_callback(cpg_handle_t handle, const struct cpg_name *gnam
 	struct clog_cpg *match;
 	int found = 0;
 
+	pthread_rwlock_rdlock(&clog_cpg_lock);
 	dm_list_iterate_items(match, &clog_cpg_list)
 		if (match->handle == handle) {
 			found = 1;
 			break;
 		}
+	pthread_rwlock_unlock(&clog_cpg_lock);
 
 	if (!found) {
 		LOG_ERROR("Unable to find match for CPG config callback");
@@ -1487,6 +1498,16 @@ static void cpg_config_callback(cpg_handle_t handle, const struct cpg_name *gnam
 	else
 		cpg_leave_callback(match, left_list,
 				   member_list, member_list_entries);
+
+
+	if (match->free_me) {
+		LOG_DBG("closing thread %x", (unsigned int)match->thread_pid);
+		free(match);
+		return;
+	}
+
+	do_checkpoints(match, 0);
+	resend_requests(match);
 }
 
 cpg_callbacks_t cpg_callbacks = {
@@ -1554,12 +1575,16 @@ int create_cluster_cpg(char *uuid, uint64_t luid)
 	size_t size;
 	struct clog_cpg *new = NULL;
 	struct clog_cpg *tmp;
+	pthread_t new_pid;
 
+	pthread_rwlock_rdlock(&clog_cpg_lock);
 	dm_list_iterate_items(tmp, &clog_cpg_list)
 		if (!strncmp(tmp->name.value, uuid, CPG_MAX_NAME_LENGTH)) {
 			LOG_ERROR("Log entry already exists: %s", uuid);
+			pthread_rwlock_unlock(&clog_cpg_lock);
 			return -EEXIST;
 		}
+	pthread_rwlock_unlock(&clog_cpg_lock);
 
 	new = malloc(sizeof(*new));
 	if (!new) {
@@ -1601,13 +1626,16 @@ int create_cluster_cpg(char *uuid, uint64_t luid)
 	}
 
 	new->cpg_state = VALID;
+	pthread_rwlock_wrlock(&clog_cpg_lock);
 	dm_list_add(&clog_cpg_list, &new->list);
+	pthread_rwlock_unlock(&clog_cpg_lock);
+
 	LOG_DBG("New   handle: %llu", (unsigned long long)new->handle);
 	LOG_DBG("New   name: %s", new->name.value);
 
-	/* FIXME: better variable */
-	cpg_fd_get(new->handle, &r);
-	links_register(r, "cluster", do_cluster_work, NULL);
+	pthread_create(&new_pid, NULL, (void *)cluster_thread_fn, (void*)new);
+	new->thread_pid = new_pid;
+	pthread_detach(new_pid);
 
 	return 0;
 }
@@ -1676,9 +1704,11 @@ int destroy_cluster_cpg(char *uuid)
 {
 	struct clog_cpg *del, *tmp;
 
+	pthread_rwlock_rdlock(&clog_cpg_lock);
 	dm_list_iterate_items_safe(del, tmp, &clog_cpg_list)
 		if (!strncmp(del->name.value, uuid, CPG_MAX_NAME_LENGTH))
 			_destroy_cluster_cpg(del);
+	pthread_rwlock_unlock(&clog_cpg_lock);
 
 	return 0;
 }
diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index f6e0918..bb6acfd 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -818,9 +818,9 @@ no_disk:
 	if (commit_log && (lc->disk_fd >= 0)) {
 		rq->error = write_log(lc);
 		if (rq->error)
-			LOG_ERROR("Failed initial disk log write");
+			LOG_ERROR("[%s] Failed initial disk log write", SHORT_UUID(lc->uuid));
 		else
-			LOG_DBG("Disk log initialized");
+			LOG_DBG("[%s] Disk log initialized", SHORT_UUID(lc->uuid));
 		lc->touched = 0;
 	}
 out:
@@ -1910,7 +1910,6 @@ void log_debug(void)
 
 	LOG_ERROR("");
 	LOG_ERROR("LOG COMPONENT DEBUGGING::");
-	LOG_ERROR("Official log list:");
 	LOG_ERROR("Pending log list:");
 	dm_list_iterate_items(lc, &log_pending_list) {
 		LOG_ERROR("%s", lc->uuid);
@@ -1920,6 +1919,7 @@ void log_debug(void)
 		print_bits(lc->clean_bits, 1);
 	}
 
+	LOG_ERROR("Official log list:");
 	dm_list_iterate_items(lc, &log_list) {
 		LOG_ERROR("%s", lc->uuid);
 		LOG_ERROR("  recoverer        : %" PRIu32, lc->recoverer);
diff --git a/daemons/cmirrord/local.c b/daemons/cmirrord/local.c
index 500f6dc..b5ccc3f 100644
--- a/daemons/cmirrord/local.c
+++ b/daemons/cmirrord/local.c
@@ -29,13 +29,13 @@
 
 static int cn_fd = -1;  /* Connector (netlink) socket fd */
 static char recv_buf[2048];
-static char send_buf[2048];
 
 
 /* FIXME: merge this function with kernel_send_helper */
 static int kernel_ack(uint32_t seq, int error)
 {
 	int r;
+	char send_buf[2048];
 	struct nlmsghdr *nlh = (struct nlmsghdr *)send_buf;
 	struct cn_msg *msg = NLMSG_DATA(nlh);
 
@@ -179,6 +179,7 @@ static int kernel_send_helper(void *data, uint16_t out_size)
 	int r;
 	struct nlmsghdr *nlh;
 	struct cn_msg *msg;
+	char send_buf[2048];
 
 	memset(send_buf, 0, sizeof(send_buf));
 
-- 
1.7.3.4


