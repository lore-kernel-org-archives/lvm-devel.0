From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  5 Jan 2015 16:07:07 +0000 (UTC)
Subject: master - cmirror: check for cmirror availability during cluster mirror creation and activation
Message-ID: <20150105160707.B2AA4601DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cba6186325f0d5806cf1ddec276b3bb8e178687a
Commit:        cba6186325f0d5806cf1ddec276b3bb8e178687a
Parent:        3e0ed83bc8103d36efe0e2dcdfd4b5ad5fd822a8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 5 16:45:30 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 5 16:54:07 2015 +0100

cmirror: check for cmirror availability during cluster mirror creation and activation

When creating/activating clustered mirrors, we should have cmirrord
available and running. If it's not, we ended up with rather cryptic
errors like:

$ lvcreate -l1 -m1 --type mirror vg
  Error locking on node 1: device-mapper: reload ioctl on  failed: Invalid argument
  Failed to activate new LV.

$ vgchange -ay vg
  Error locking on node node 1: device-mapper: reload ioctl on failed: Invalid argument

This patch adds check for cmirror availability and it errors out
properly, also giving a more precise error messge so users are able
to identify the source of the problem easily:

$ lvcreate -l1 -m1 --type mirror vg
  Shared cluster mirrors are not available.

$ vgchange -ay vg
  Error locking on node 1: Shared cluster mirrors are not available.

Exclusively activated cluster mirror LVs are OK even without cmirrord:

$ vgchange -aey vg
  1 logical volume(s) in volume group "vg" now active
---
 WHATS_NEW                        |    1 +
 lib/activate/activate.c          |   10 ++++++++++
 lib/metadata/lv_manip.c          |    7 +++++++
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/mirror.c            |    7 +++----
 5 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cc11a9a..c1a38c7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Check for cmirror availability during cluster mirror creation and activation.
   Add cache_policy and cache_settings reporting fields.
   Add missing recognition for --binary option with {pv,vg,lv}display -C.
   Fix vgimportclone to notify lvmetad about changes done if lvmetad is used.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index dd0a4f9..c63cbde 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2203,6 +2203,16 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	/*
+	 * Check if cmirord is running for clustered mirrors.
+	 */
+	if (!laopts->exclusive && vg_is_clustered(lv->vg) &&
+	    lv_is_mirror(lv) && !lv_is_raid(lv) &&
+	    !cluster_mirror_is_available(lv->vg->cmd)) {
+		log_error("Shared cluster mirrors are not available.");
+		goto out;
+	}
+
 	if (test_mode()) {
 		_skip("Activating '%s'.", lv->name);
 		r = 1;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4483fba..260a76a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6817,6 +6817,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		if (!(create_segtype = get_segtype_from_string(vg->cmd, "striped")))
 			return_0;
 	} else if (seg_is_mirrored(lp) || seg_is_raid(lp)) {
+		if (lp->activate != CHANGE_AEY && vg_is_clustered(vg) &&
+		    seg_is_mirrored(lp) && !seg_is_raid(lp) &&
+		    !cluster_mirror_is_available(vg->cmd)) {
+			log_error("Shared cluster mirrors are not available.");
+			return NULL;
+		}
+
 		/* FIXME This will not pass cluster lock! */
 		init_mirror_in_sync(lp->nosync);
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d70602d..b8946ba 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1017,6 +1017,7 @@ int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 const char *get_mirror_log_name(int log_count);
 int set_mirror_log_count(int *log_count, const char *mirrorlog);
 
+int cluster_mirror_is_available(struct cmd_context *cmd);
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
 uint32_t lv_mirror_count(const struct logical_volume *lv);
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index d0b1ebf..bac1ffb 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -78,10 +78,9 @@ struct logical_volume *find_temporary_mirror(const struct logical_volume *lv)
  *
  * Returns: 1 if available, 0 otherwise
  */
-static int _cluster_mirror_is_available(struct logical_volume *lv)
+int cluster_mirror_is_available(struct cmd_context *cmd)
 {
        unsigned attr = 0;
-       struct cmd_context *cmd = lv->vg->cmd;
        const struct segment_type *segtype;
 
        if (!(segtype = get_segtype_from_string(cmd, "mirror")))
@@ -90,7 +89,7 @@ static int _cluster_mirror_is_available(struct logical_volume *lv)
        if (!segtype->ops->target_present)
                return_0;
 
-       if (!segtype->ops->target_present(lv->vg->cmd, NULL, &attr))
+       if (!segtype->ops->target_present(cmd, NULL, &attr))
                return_0;
 
        if (!(attr & MIRROR_LOG_CLUSTERED))
@@ -2127,7 +2126,7 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!lv_is_pvmove(lv) && !lv_is_locked(lv) &&
 		    lv_is_active(lv) &&
 		    !lv_is_active_exclusive_locally(lv) && /* lv_is_active_remotely */
-		    !_cluster_mirror_is_available(lv)) {
+		    !cluster_mirror_is_available(lv->vg->cmd)) {
 			log_error("Shared cluster mirrors are not available.");
 			return 0;
 		}


