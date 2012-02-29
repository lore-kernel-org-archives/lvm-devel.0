From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 29 Feb 2012 08:00:03 -0600
Subject: [PATCH] Allow cluster mirrors to handle the absence of the checkpoint lib (libSaCkpt).
Message-ID: <1330524003.21136.5.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In the patch below, I conditionally replace some functions based on
whether the checkpoint library exists.  There are ways to make the code
handle both methods of checkpointing, but I chose to make it do
exclusively one or the other.  This is because the cluster will likely
be restarted when the cluster libraries are upgraded and checkpointing
is lost.  (IOW, this solution does not allow rolling upgrades, but I
don't think it needs to.)

Please take a good look at my changes to 'configure.in' also.

 brassow

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


Index: LVM2/daemons/cmirrord/cluster.c
===================================================================
--- LVM2.orig/daemons/cmirrord/cluster.c
+++ LVM2/daemons/cmirrord/cluster.c
@@ -20,10 +20,12 @@
 
 #include <corosync/cpg.h>
 #include <errno.h>
-#include <openais/saAis.h>
-#include <openais/saCkpt.h>
 #include <signal.h>
 #include <unistd.h>
+#ifdef __HAS_OPENAIS_CHECKPOINT__
+#include <openais/saAis.h>
+#include <openais/saCkpt.h>
+#endif
 
 /* Open AIS error codes */
 #define str_ais_error(x)						\
@@ -62,13 +64,13 @@
 	RQ_TYPE((x) & ~DM_ULOG_RESPONSE)
 
 static uint32_t my_cluster_id = 0xDEAD;
+#ifdef __HAS_OPENAIS_CHECKPOINT__
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
@@ -77,6 +79,7 @@ static SaVersionT version = { 'B', 1, 1 
 
 static int log_resp_rec = 0;
 
+#define RECOVERING_REGION_SECTION_SIZE 64
 struct checkpoint_data {
 	uint32_t requester;
 	char uuid[CPG_MAX_NAME_LENGTH];
@@ -128,7 +131,6 @@ static struct dm_list clog_cpg_list;
 int cluster_send(struct clog_request *rq)
 {
 	int r;
-	int count=0;
 	int found = 0;
 	struct iovec iov;
 	struct clog_cpg *entry;
@@ -165,7 +167,10 @@ int cluster_send(struct clog_request *rq
 	if (entry->cpg_state != VALID)
 		return -EINVAL;
 
+#ifdef __HAS_OPENAIS_CHECKPOINT__
 	do {
+		int count = 0;
+
 		r = cpg_mcast_joined(entry->handle, CPG_TYPE_AGREED, &iov, 1);
 		if (r != SA_AIS_ERR_TRY_AGAIN)
 			break;
@@ -189,12 +194,14 @@ int cluster_send(struct clog_request *rq
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
@@ -419,6 +426,7 @@ static void free_checkpoint(struct check
 	free(cp);
 }
 
+#ifdef __HAS_OPENAIS_CHECKPOINT__
 static int export_checkpoint(struct checkpoint_data *cp)
 {
 	SaCkptCheckpointCreationAttributesT attr;
@@ -587,7 +595,55 @@ rr_create_retry:
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
+	LOG_ERROR("Allocating %d bytes for Checkpoint RQ", rq_size);
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
+	rq->originator = cp->requester;  /* FIXME: hack to overload meaning of originator */
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
+#endif /* __HAS_OPENAIS_CHECKPOINT__ */
+
+#ifdef __HAS_OPENAIS_CHECKPOINT__
+static int import_checkpoint(struct clog_cpg *entry, int no_read,
+			     struct clog_request *rq __attribute__((unused)))
 {
 	int rtn = 0;
 	SaCkptCheckpointHandleT h;
@@ -742,6 +798,44 @@ no_read:
 	return rtn;
 }
 
+#else
+static int import_checkpoint(struct clog_cpg *entry, int no_read,
+			     struct clog_request *rq)
+{
+	int bitmap_size;
+
+	/*
+	 * The old method of transfering start-up log state depended
+	 * on OpenAIS checkpointing.  The log state was transferred through
+	 * checkpointing and the DM_ULOG_CHECKPOINT_READY request contained
+	 * no data.
+	 *
+	 * The new method carries the log state with the request.
+	 */
+	if (!rq->u_rq.data_size)
+		return _import_checkpoint_v1(entry, no_read);
+
+	LOG_ERROR("Importing checkpoint - version 2");
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
+#endif /* __HAS_OPENAIS_CHECKPOINT__ */
+
 static void do_checkpoints(struct clog_cpg *entry, int leaving)
 {
 	struct checkpoint_data *cp;
@@ -859,13 +953,13 @@ static int resend_requests(struct clog_c
 
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
@@ -876,7 +970,7 @@ static int do_cluster_work(void *data __
 		resend_requests(entry);
 	}
 
-	return (r == SA_AIS_OK) ? 0 : -1;  /* FIXME: good error number? */
+	return (r == CPG_OK) ? 0 : -1;  /* FIXME: good error number? */
 }
 
 static int flush_startup_list(struct clog_cpg *entry)
@@ -941,16 +1035,19 @@ static void cpg_message_callback(cpg_han
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
@@ -969,7 +1066,7 @@ static void cpg_message_callback(cpg_han
 		}
 		memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
 		dm_list_init(&tmp_rq->u.list);
-		dm_list_add( &match->working_list, &tmp_rq->u.list);
+		dm_list_add(&match->working_list, &tmp_rq->u.list);
 	}
 
 	if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND) {
@@ -1022,7 +1119,8 @@ static void cpg_message_callback(cpg_han
 			/* Redundant checkpoints ignored if match->valid */
 			LOG_SPRINT(match, "[%s] CHECKPOINT_READY notification from %u",
 				   SHORT_UUID(rq->u_rq.uuid), nodeid);
-			if (import_checkpoint(match, (match->state != INVALID))) {
+			if (import_checkpoint(match,
+					      (match->state != INVALID), rq)) {
 				LOG_SPRINT(match,
 					   "[%s] Failed to import checkpoint from %u",
 					   SHORT_UUID(rq->u_rq.uuid), nodeid);
@@ -1415,6 +1513,7 @@ cpg_callbacks_t cpg_callbacks = {
  */
 static int remove_checkpoint(struct clog_cpg *entry)
 {
+#ifdef __HAS_OPENAIS_CHECKPOINT__
 	int len;
 	SaNameT name;
 	SaAisErrorT rv;
@@ -1454,6 +1553,10 @@ unlink_retry:
 	saCkptCheckpointClose(h);
 
 	return 1;
+#else
+	/* No checkpoint to remove, so 'success' */
+	return 1;
+#endif
 }
 
 int create_cluster_cpg(char *uuid, uint64_t luid)
@@ -1495,14 +1598,14 @@ int create_cluster_cpg(char *uuid, uint6
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
@@ -1593,24 +1696,27 @@ int destroy_cluster_cpg(char *uuid)
 
 int init_cluster(void)
 {
+#ifdef __HAS_OPENAIS_CHECKPOINT__
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
+#ifdef __HAS_OPENAIS_CHECKPOINT__
 	SaAisErrorT err;
 
 	err = saCkptFinalize(ckpt_handle);
 	if (err != SA_AIS_OK)
 		LOG_ERROR("Failed to finalize checkpoint handle");
+#endif
 }
 
 void cluster_debug(void)
Index: LVM2/configure
===================================================================
--- LVM2.orig/configure
+++ LVM2/configure
@@ -668,6 +668,7 @@ DEFAULT_SYS_DIR
 DEBUG
 COPTIMISE_FLAG
 CONFDIR
+CMIRROR_HAS_CHECKPOINT
 CMDLIB
 CLVMD_PATH
 CLVMD_CMANAGERS
@@ -8198,6 +8199,8 @@ if [ "x$BUILD_CMIRRORD" = xyes ]; then
 		pkg_config_init
 	fi
 
+	CMIRROR_HAS_CHECKPOINT=yes
+
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for SACKPT" >&5
 $as_echo_n "checking for SACKPT... " >&6; }
@@ -8254,40 +8257,23 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$SACKPT_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (libSaCkpt) were not met:
-
-$SACKPT_PKG_ERRORS
-
-Consider adjusting the PKG_CONFIG_PATH environment variable if you
-installed software in a non-standard prefix.
-
-Alternatively, you may set the environment variables SACKPT_CFLAGS
-and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." "$LINENO" 5
-
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no libSaCkpt, compiling without it" >&5
+$as_echo "no libSaCkpt, compiling without it" >&6; }
+		CMIRROR_HAS_CHECKPOINT=no
 elif test $pkg_failed = untried; then
      	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
-	{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
-as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
-is in your PATH or set the PKG_CONFIG environment variable to the full
-path to pkg-config.
-
-Alternatively, you may set the environment variables SACKPT_CFLAGS
-and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-
-To get pkg-config, see <http://pkg-config.freedesktop.org/>.
-See \`config.log' for more details" "$LINENO" 5; }
-
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no libSaCkpt, compiling without it" >&5
+$as_echo "no libSaCkpt, compiling without it" >&6; }
+		CMIRROR_HAS_CHECKPOINT=no
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
@@ -10425,6 +10411,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]'
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
Index: LVM2/configure.in
===================================================================
--- LVM2.orig/configure.in
+++ LVM2/configure.in
@@ -740,7 +740,12 @@ if [[ "x$BUILD_CMIRRORD" = xyes ]]; then
 	if  test x$PKGCONFIG_INIT != x1; then
 		pkg_config_init
 	fi
-	PKG_CHECK_MODULES(SACKPT, libSaCkpt)
+
+	CMIRROR_HAS_CHECKPOINT=yes
+	PKG_CHECK_MODULES(SACKPT, libSaCkpt, [HAVE_SACKPT=yes],
+		[AC_MSG_RESULT([no libSaCkpt, compiling without it])
+		CMIRROR_HAS_CHECKPOINT=no])
+
 	if test x$HAVE_CPG != xyes; then
 		PKG_CHECK_MODULES(CPG, libcpg)
 	fi
@@ -1394,6 +1399,7 @@ AC_SUBST(CMAN_LIBS)
 AC_SUBST(CMAP_CFLAGS)
 AC_SUBST(CMAP_LIBS)
 AC_SUBST(CMDLIB)
+AC_SUBST(CMIRROR_HAS_CHECKPOINT)
 AC_SUBST(CONFDB_CFLAGS)
 AC_SUBST(CONFDB_LIBS)
 AC_SUBST(CONFDIR)
Index: LVM2/daemons/cmirrord/Makefile.in
===================================================================
--- LVM2.orig/daemons/cmirrord/Makefile.in
+++ LVM2/daemons/cmirrord/Makefile.in
@@ -30,6 +30,10 @@ LIBS += -ldevmapper
 LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
 CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS)
 
+ifeq ("@CMIRROR_HAS_CHECKPOINT@", "yes")
+	CFLAGS += -D__HAS_OPENAIS_CHECKPOINT__
+endif
+
 cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)




