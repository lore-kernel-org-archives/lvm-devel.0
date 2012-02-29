From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 29 Feb 2012 21:15:35 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in da ...
Message-ID: <20120229211535.25200.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-29 21:15:35

Modified files:
	.              : WHATS_NEW configure configure.in 
	daemons/cmirrord: cluster.c 
	lib/misc       : configure.h.in 

Log message:
	Allow cluster mirrors to handle the absence of the checkpoint lib (libSaCkpt).
	
	The OpenAIS checkpoint library is going away; therefore, cmirrord must
	operate without it.  The algorithms the handle the timing of when to send
	a checkpoint, the determination of what to send, and which ongoing cluster
	requests are relevent with respect to the checkpoints are unaffected.  We
	need only replace the functions that actually perform the storing/transmitting
	and retrieving/receiving of the checkpoint data.  Rather than store the
	checkpoint data in an OpenAIS checkpoint file, we simply transmit it along
	with the message that notifies the incoming node that the checkpoint is
	ready.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2325&r2=1.2326
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.174&r2=1.175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.189&r2=1.190
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2012/02/28 14:23:41	1.2325
+++ LVM2/WHATS_NEW	2012/02/29 21:15:34	1.2326
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Allow cluster mirrors to handle the absence of the checkpoint lib (libSaCkpt).
   Revert free of allocated segtype in init segment error path (2.02.89).
   Test dm_hash_insert() failures in filter-persistent.c and fid_add_mda().
   Ensure clvmd message is always \0 terminated after read.
--- LVM2/configure	2012/02/28 18:35:04	1.174
+++ LVM2/configure	2012/02/29 21:15:34	1.175
@@ -8198,6 +8198,10 @@
 		pkg_config_init
 	fi
 
+
+$as_echo "#define CMIRROR_HAS_CHECKPOINT 1" >>confdefs.h
+
+
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for SACKPT" >&5
 $as_echo_n "checking for SACKPT... " >&6; }
@@ -8254,40 +8258,27 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$SACKPT_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (libSaCkpt) were not met:
-
-$SACKPT_PKG_ERRORS
-
-Consider adjusting the PKG_CONFIG_PATH environment variable if you
-installed software in a non-standard prefix.
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no libSaCkpt, compiling without it" >&5
+$as_echo "no libSaCkpt, compiling without it" >&6; }
 
-Alternatively, you may set the environment variables SACKPT_CFLAGS
-and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." "$LINENO" 5
+$as_echo "#define CMIRROR_HAS_CHECKPOINT 0" >>confdefs.h
 
 elif test $pkg_failed = untried; then
      	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
-	{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
-as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
-is in your PATH or set the PKG_CONFIG environment variable to the full
-path to pkg-config.
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no libSaCkpt, compiling without it" >&5
+$as_echo "no libSaCkpt, compiling without it" >&6; }
 
-Alternatively, you may set the environment variables SACKPT_CFLAGS
-and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-
-To get pkg-config, see <http://pkg-config.freedesktop.org/>.
-See \`config.log' for more details" "$LINENO" 5; }
+$as_echo "#define CMIRROR_HAS_CHECKPOINT 0" >>confdefs.h
 
 else
 	SACKPT_CFLAGS=$pkg_cv_SACKPT_CFLAGS
 	SACKPT_LIBS=$pkg_cv_SACKPT_LIBS
         { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
-
+	HAVE_SACKPT=yes
 fi
+
 	if test x$HAVE_CPG != xyes; then
 
 pkg_failed=no
--- LVM2/configure.in	2012/02/28 18:18:48	1.189
+++ LVM2/configure.in	2012/02/29 21:15:34	1.190
@@ -740,7 +740,12 @@
 	if  test x$PKGCONFIG_INIT != x1; then
 		pkg_config_init
 	fi
-	PKG_CHECK_MODULES(SACKPT, libSaCkpt)
+
+	AC_DEFINE([CMIRROR_HAS_CHECKPOINT], 1, [Define to 1 to include libSaCkpt.])
+	PKG_CHECK_MODULES(SACKPT, libSaCkpt, [HAVE_SACKPT=yes],
+		[AC_MSG_RESULT([no libSaCkpt, compiling without it])
+		AC_DEFINE([CMIRROR_HAS_CHECKPOINT], 0, [Define to 0 to exclude libSaCkpt.])])
+
 	if test x$HAVE_CPG != xyes; then
 		PKG_CHECK_MODULES(CPG, libcpg)
 	fi
--- LVM2/daemons/cmirrord/cluster.c	2011/09/06 18:15:43	1.17
+++ LVM2/daemons/cmirrord/cluster.c	2012/02/29 21:15:34	1.18
@@ -20,10 +20,12 @@
 
 #include <corosync/cpg.h>
 #include <errno.h>
-#include <openais/saAis.h>
-#include <openais/saCkpt.h>
 #include <signal.h>
 #include <unistd.h>
+#if CMIRROR_HAS_CHECKPOINT
+#include <openais/saAis.h>
+#include <openais/saCkpt.h>
+#endif
 
 /* Open AIS error codes */
 #define str_ais_error(x)						\
@@ -62,13 +64,13 @@
 	RQ_TYPE((x) & ~DM_ULOG_RESPONSE)
 
 static uint32_t my_cluster_id = 0xDEAD;
+#if CMIRROR_HAS_CHECKPOINT
 static SaCkptHandleT ckpt_handle = 0;
 static SaCkptCallbacksT callbacks = { 0, 0 };
 static SaVersionT version = { 'B', 1, 1 };
+#endif
 
 #define DEBUGGING_HISTORY 100
-//static char debugging[DEBUGGING_HISTORY][128];
-//static int idx = 0;
 #define LOG_SPRINT(cc, f, arg...) do {				\
 		cc->idx++;					\
 		cc->idx = cc->idx % DEBUGGING_HISTORY;		\
@@ -77,6 +79,7 @@
 
 static int log_resp_rec = 0;
 
+#define RECOVERING_REGION_SECTION_SIZE 64
 struct checkpoint_data {
 	uint32_t requester;
 	char uuid[CPG_MAX_NAME_LENGTH];
@@ -128,7 +131,6 @@
 int cluster_send(struct clog_request *rq)
 {
 	int r;
-	int count=0;
 	int found = 0;
 	struct iovec iov;
 	struct clog_cpg *entry;
@@ -165,7 +167,10 @@
 	if (entry->cpg_state != VALID)
 		return -EINVAL;
 
+#if CMIRROR_HAS_CHECKPOINT
 	do {
+		int count = 0;
+
 		r = cpg_mcast_joined(entry->handle, CPG_TYPE_AGREED, &iov, 1);
 		if (r != SA_AIS_ERR_TRY_AGAIN)
 			break;
@@ -189,12 +194,14 @@
 				  str_ais_error(r));
 		usleep(1000);
 	} while (1);
-
+#else
+	r = cpg_mcast_joined(entry->handle, CPG_TYPE_AGREED, &iov, 1);
+#endif
 	if (r == CPG_OK)
 		return 0;
 
 	/* error codes found in openais/cpg.h */
-	LOG_ERROR("cpg_mcast_joined error: %s", str_ais_error(r));
+	LOG_ERROR("cpg_mcast_joined error: %d", r);
 
 	rq->u_rq.error = -EBADE;
 	return -EBADE;
@@ -419,6 +426,7 @@
 	free(cp);
 }
 
+#if CMIRROR_HAS_CHECKPOINT
 static int export_checkpoint(struct checkpoint_data *cp)
 {
 	SaCkptCheckpointCreationAttributesT attr;
@@ -587,7 +595,54 @@
 	return 0;
 }
 
-static int import_checkpoint(struct clog_cpg *entry, int no_read)
+#else
+static int export_checkpoint(struct checkpoint_data *cp)
+{
+	int r, rq_size;
+	struct clog_request *rq;
+
+	rq_size = sizeof(*rq);
+	rq_size += RECOVERING_REGION_SECTION_SIZE;
+	rq_size += cp->bitmap_size * 2; /* clean|sync_bits */
+
+	rq = malloc(rq_size);
+	if (!rq) {
+		LOG_ERROR("export_checkpoint: "
+			  "Unable to allocate transfer structs");
+		return -ENOMEM;
+	}
+	memset(rq, 0, rq_size);
+
+	dm_list_init(&rq->u.list);
+	rq->u_rq.request_type = DM_ULOG_CHECKPOINT_READY;
+	rq->originator = cp->requester;
+	strncpy(rq->u_rq.uuid, cp->uuid, CPG_MAX_NAME_LENGTH);
+	rq->u_rq.seq = my_cluster_id;
+	rq->u_rq.data_size = rq_size - sizeof(*rq);
+
+	/* Sync bits */
+	memcpy(rq->u_rq.data, cp->sync_bits, cp->bitmap_size);
+
+	/* Clean bits */
+	memcpy(rq->u_rq.data + cp->bitmap_size, cp->clean_bits, cp->bitmap_size);
+
+	/* Recovering region */
+	memcpy(rq->u_rq.data + (cp->bitmap_size * 2), cp->recovering_region,
+	       strlen(cp->recovering_region));
+
+	r = cluster_send(rq);
+	if (r)
+		LOG_ERROR("Failed to send checkpoint ready notice: %s",
+			  strerror(-r));
+
+	free(rq);
+	return 0;
+}
+#endif /* CMIRROR_HAS_CHECKPOINT */
+
+#if CMIRROR_HAS_CHECKPOINT
+static int import_checkpoint(struct clog_cpg *entry, int no_read,
+			     struct clog_request *rq __attribute__((unused)))
 {
 	int rtn = 0;
 	SaCkptCheckpointHandleT h;
@@ -742,6 +797,32 @@
 	return rtn;
 }
 
+#else
+static int import_checkpoint(struct clog_cpg *entry, int no_read,
+			     struct clog_request *rq)
+{
+	int bitmap_size;
+
+	bitmap_size = (rq->u_rq.data_size - RECOVERING_REGION_SECTION_SIZE) / 2;
+	if (bitmap_size < 0) {
+		LOG_ERROR("Checkpoint has invalid payload size.");
+		return -EINVAL;
+	}
+
+	if (pull_state(entry->name.value, entry->luid, "sync_bits",
+		       rq->u_rq.data, bitmap_size) ||
+	    pull_state(entry->name.value, entry->luid, "clean_bits",
+		       rq->u_rq.data + bitmap_size, bitmap_size) ||
+	    pull_state(entry->name.value, entry->luid, "recovering_region",
+		       rq->u_rq.data + (bitmap_size * 2),
+		       RECOVERING_REGION_SECTION_SIZE)) {
+		LOG_ERROR("Error loading bitmap state from checkpoint.");
+		return -EIO;
+	}
+	return 0;
+}
+#endif /* CMIRROR_HAS_CHECKPOINT */
+
 static void do_checkpoints(struct clog_cpg *entry, int leaving)
 {
 	struct checkpoint_data *cp;
@@ -859,13 +940,13 @@
 
 static int do_cluster_work(void *data __attribute__((unused)))
 {
-	int r = SA_AIS_OK;
+	int r = CPG_OK;
 	struct clog_cpg *entry, *tmp;
 
 	dm_list_iterate_items_safe(entry, tmp, &clog_cpg_list) {
 		r = cpg_dispatch(entry->handle, CPG_DISPATCH_ALL);
-		if (r != SA_AIS_OK)
-			LOG_ERROR("cpg_dispatch failed: %s", str_ais_error(r));
+		if (r != CPG_OK)
+			LOG_ERROR("cpg_dispatch failed: %d", r);
 
 		if (entry->free_me) {
 			free(entry);
@@ -876,7 +957,7 @@
 		resend_requests(entry);
 	}
 
-	return (r == SA_AIS_OK) ? 0 : -1;  /* FIXME: good error number? */
+	return (r == CPG_OK) ? 0 : -1;  /* FIXME: good error number? */
 }
 
 static int flush_startup_list(struct clog_cpg *entry)
@@ -941,16 +1022,19 @@
 	struct clog_request *tmp_rq;
 	struct clog_cpg *match;
 
-	if (clog_request_from_network(rq, msg_len) < 0)
-		/* Error message comes from 'clog_request_from_network' */
-		return;
-
 	match = find_clog_cpg(handle);
 	if (!match) {
 		LOG_ERROR("Unable to find clog_cpg for cluster message");
 		return;
 	}
 
+	/*
+	 * Perform necessary endian and version compatibility conversions
+	 */
+	if (clog_request_from_network(rq, msg_len) < 0)
+		/* Any error messages come from 'clog_request_from_network' */
+		return;
+
 	if ((nodeid == my_cluster_id) &&
 	    !(rq->u_rq.request_type & DM_ULOG_RESPONSE) &&
 	    (rq->u_rq.request_type != DM_ULOG_RESUME) &&
@@ -969,7 +1053,7 @@
 		}
 		memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
 		dm_list_init(&tmp_rq->u.list);
-		dm_list_add( &match->working_list, &tmp_rq->u.list);
+		dm_list_add(&match->working_list, &tmp_rq->u.list);
 	}
 
 	if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND) {
@@ -1022,7 +1106,8 @@
 			/* Redundant checkpoints ignored if match->valid */
 			LOG_SPRINT(match, "[%s] CHECKPOINT_READY notification from %u",
 				   SHORT_UUID(rq->u_rq.uuid), nodeid);
-			if (import_checkpoint(match, (match->state != INVALID))) {
+			if (import_checkpoint(match,
+					      (match->state != INVALID), rq)) {
 				LOG_SPRINT(match,
 					   "[%s] Failed to import checkpoint from %u",
 					   SHORT_UUID(rq->u_rq.uuid), nodeid);
@@ -1415,6 +1500,7 @@
  */
 static int remove_checkpoint(struct clog_cpg *entry)
 {
+#if CMIRROR_HAS_CHECKPOINT
 	int len;
 	SaNameT name;
 	SaAisErrorT rv;
@@ -1454,6 +1540,10 @@
 	saCkptCheckpointClose(h);
 
 	return 1;
+#else
+	/* No checkpoint to remove, so 'success' */
+	return 1;
+#endif
 }
 
 int create_cluster_cpg(char *uuid, uint64_t luid)
@@ -1495,14 +1585,14 @@
 			 SHORT_UUID(new->name.value));
 
 	r = cpg_initialize(&new->handle, &cpg_callbacks);
-	if (r != SA_AIS_OK) {
+	if (r != CPG_OK) {
 		LOG_ERROR("cpg_initialize failed:  Cannot join cluster");
 		free(new);
 		return -EPERM;
 	}
 
 	r = cpg_join(new->handle, &new->name);
-	if (r != SA_AIS_OK) {
+	if (r != CPG_OK) {
 		LOG_ERROR("cpg_join failed:  Cannot join cluster");
 		free(new);
 		return -EPERM;
@@ -1593,24 +1683,27 @@
 
 int init_cluster(void)
 {
+#if CMIRROR_HAS_CHECKPOINT
 	SaAisErrorT rv;
 
-	dm_list_init(&clog_cpg_list);
 	rv = saCkptInitialize(&ckpt_handle, &callbacks, &version);
 
 	if (rv != SA_AIS_OK)
 		return EXIT_CLUSTER_CKPT_INIT;
-
+#endif
+	dm_list_init(&clog_cpg_list);
 	return 0;
 }
 
 void cleanup_cluster(void)
 {
+#if CMIRROR_HAS_CHECKPOINT
 	SaAisErrorT err;
 
 	err = saCkptFinalize(ckpt_handle);
 	if (err != SA_AIS_OK)
 		LOG_ERROR("Failed to finalize checkpoint handle");
+#endif
 }
 
 void cluster_debug(void)
--- LVM2/lib/misc/configure.h.in	2012/02/28 18:20:58	1.38
+++ LVM2/lib/misc/configure.h.in	2012/02/29 21:15:34	1.39
@@ -15,6 +15,9 @@
 /* Path to cmirrord pidfile. */
 #undef CMIRRORD_PIDFILE
 
+/* Define to 0 to exclude libSaCkpt. */
+#undef CMIRROR_HAS_CHECKPOINT
+
 /* Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP
    systems. This function is required for `alloca.c' support on those systems.
    */


