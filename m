From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 24 Jun 2014 12:59:04 +0000 (UTC)
Subject: master - coverity: fix issues reported by coverity
Message-ID: <20140624125904.97E36606F9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3208396ce5ef1c754e8e164f84dbc97727ddb5a4
Commit:        3208396ce5ef1c754e8e164f84dbc97727ddb5a4
Parent:        29ca0573baa0172ae9e1b137c51c39446baa9ee9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 24 14:58:53 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 24 14:58:53 2014 +0200

coverity: fix issues reported by coverity

---
 daemons/clvmd/clvmd-cman.c       |   10 +++++-----
 lib/commands/toolcontext.c       |    5 ++++-
 lib/config/config.c              |    3 +--
 lib/metadata/metadata.c          |    2 +-
 lib/metadata/raid_manip.c        |    2 +-
 libdaemon/server/daemon-server.c |    3 ++-
 libdm/libdm-report.c             |   12 ++++++------
 7 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/daemons/clvmd/clvmd-cman.c b/daemons/clvmd/clvmd-cman.c
index e41d0cf..9efa92d 100644
--- a/daemons/clvmd/clvmd-cman.c
+++ b/daemons/clvmd/clvmd-cman.c
@@ -110,12 +110,12 @@ static void _cluster_init_completed(void)
 	clvmd_cluster_init_completed();
 }
 
-static int _get_main_cluster_fd()
+static int _get_main_cluster_fd(void)
 {
 	return cman_get_fd(c_handle);
 }
 
-static int _get_num_nodes()
+static int _get_num_nodes(void)
 {
 	int i;
 	int nnodes = 0;
@@ -243,7 +243,7 @@ static void _add_up_node(const char *csid)
 	DEBUGLOG("Added new node %d to updown list\n", nodeid);
 }
 
-static void _cluster_closedown()
+static void _cluster_closedown(void)
 {
 	dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 1);
 	cman_finish(c_handle);
@@ -282,7 +282,7 @@ static void count_clvmds_running(void)
 }
 
 /* Get a list of active cluster members */
-static void get_members()
+static void get_members(void)
 {
 	int retnodes;
 	int status;
@@ -380,7 +380,7 @@ static int nodeid_from_csid(const char *csid)
 	return nodeid;
 }
 
-static int _is_quorate()
+static int _is_quorate(void)
 {
 	return cman_is_quorate(c_handle);
 }
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 326bfe0..18fa12d 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -642,7 +642,10 @@ static int _init_profiles(struct cmd_context *cmd)
 		dm_list_init(&cmd->profile_params->profiles);
 	}
 
-	dm_strncpy(cmd->profile_params->dir, dir, sizeof(cmd->profile_params->dir));
+	if (!(dm_strncpy(cmd->profile_params->dir, dir, sizeof(cmd->profile_params->dir)))) {
+		log_error("_init_profiles: dm_strncpy failed");
+		return 0;
+	}
 
 	return 1;
 }
diff --git a/lib/config/config.c b/lib/config/config.c
index ecb674e..2ed3db6 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -334,7 +334,7 @@ struct dm_config_tree *remove_config_tree_by_source(struct cmd_context *cmd,
 struct cft_check_handle *get_config_tree_check_handle(struct cmd_context *cmd,
 						      struct dm_config_tree *cft)
 {
-	struct config_source *cs = dm_config_get_custom(cft);
+	struct config_source *cs;
 
 	if (!(cs = dm_config_get_custom(cft)))
 		return NULL;
@@ -438,7 +438,6 @@ static int _override_config_tree_from_metadata_profile(struct cmd_context *cmd,
 	if (cs->type == CONFIG_PROFILE_COMMAND) {
 		cft_previous = cft;
 		cft = cft->cascade;
-		cs = dm_config_get_custom(cft);
 	}
 
 	cs = dm_config_get_custom(cft);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5c0a474..599ebb6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -370,7 +370,7 @@ static int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	/* FIXME: handle tags */
 	if (!(pvl = find_pv_in_vg(vg_from, pv_name))) {
 		if (!enforce_pv_from_source &&
-		    (pvl = find_pv_in_vg(vg_to, pv_name)))
+		    find_pv_in_vg(vg_to, pv_name))
 			/*
 			 * PV has already been moved.  This can happen if an
 			 * LV is being moved that has multiple sub-LVs on the
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4c13b66..cdfbc84 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -865,7 +865,7 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 			    (first_seg(seg_metalv(seg, s))->segtype != error_segtype))
 				continue;
 
-			if (target_pvs && !dm_list_empty(target_pvs) &&
+			if (!dm_list_empty(target_pvs) &&
 			    (target_pvs != &lv->vg->pvs)) {
 				/*
 				 * User has supplied a list of PVs, but we
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 8ed3cce..3b390a3 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -497,7 +497,8 @@ static void reap(daemon_state s, int waiting)
 
 	while (ts) {
 		if (waiting || !ts->active) {
-			pthread_join(ts->client.thread_id, &rv);
+			if ((errno = pthread_join(ts->client.thread_id, &rv)))
+				ERROR(&s, "pthread_join failed: %s", strerror(errno));
 			last->next = ts->next;
 			dm_free(ts);
 		} else
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 957a4c9..180bb9b 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1050,14 +1050,14 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 	struct dm_report *rh;
 	const struct dm_report_object_type *type;
 
+	if (_contains_reserved_report_type(types))
+		return_NULL;
+
 	if (!(rh = dm_zalloc(sizeof(*rh)))) {
 		log_error("dm_report_init: dm_malloc failed");
-		return 0;
+		return NULL;
 	}
 
-	if (_contains_reserved_report_type(types))
-		return_0;
-
 	/*
 	 * rh->report_types is updated in _parse_fields() and _parse_keys()
 	 * to contain all types corresponding to the fields specified by
@@ -1432,7 +1432,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 
 	if (!rh) {
 		log_error(INTERNAL_ERROR "dm_report handler is NULL.");
-		goto out;
+		return 0;
 	}
 
 	if (rh->flags & RH_ALREADY_REPORTED)
@@ -1440,7 +1440,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 
 	if (!(row = dm_pool_zalloc(rh->mem, sizeof(*row)))) {
 		log_error("dm_report_object: struct row allocation failed");
-		goto out;
+		return 0;
 	}
 
 	row->rh = rh;


