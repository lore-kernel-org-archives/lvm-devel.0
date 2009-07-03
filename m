From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri,  3 Jul 2009 10:08:20 -0400
Subject: [PATCH] Fix vg_read() error paths to properly release upon vg_read_error().
Message-ID: <1246630100-26016-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix vg_read() error paths to properly release upon vg_read_error().
Note that in the code paths called from process_each_vg(), we release
inside the iterator so no individual cleanup is needed.  However there
are a number of other places we missed the cleanup.  Proper cleanup
when vg_read_error() is true should be calling vg_release(vg), since
there should be no locks held if we get an error (except in certain
special cases, which IMO we should work to remove from the code).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvcreate.c   |    4 +++-
 tools/lvrename.c   |    4 +++-
 tools/lvresize.c   |    1 +
 tools/polldaemon.c |    1 +
 tools/pvdisplay.c  |    1 +
 tools/pvmove.c     |    1 +
 tools/pvresize.c   |    8 +++-----
 tools/reporter.c   |    1 +
 tools/toollib.c    |    1 +
 tools/vgextend.c   |    1 +
 tools/vgmerge.c    |    6 ++++--
 tools/vgrename.c   |    4 +++-
 tools/vgscan.c     |    1 +
 tools/vgsplit.c    |    4 +++-
 14 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 030aa0c..70f237a 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -995,8 +995,10 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		vg_release(vg);
 		return ECMD_FAILED;
+	}
 
 	if (!_lvcreate(cmd, vg, &lp))
 		r = ECMD_FAILED;
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 53ea116..7411854 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -103,8 +103,10 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		vg_release(vg);
 		return ECMD_FAILED;
+	}
 
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
 		log_error("Existing logical volume \"%s\" not found in "
diff --git a/tools/lvresize.c b/tools/lvresize.c
index b558792..033078f 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -673,6 +673,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Finding volume group %s", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
+		vg_release(vg);
 		stack;
 		return ECMD_FAILED;
 	}
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 8c5c7da..4dcbc22 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -150,6 +150,7 @@ static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name, co
 		/* Locks the (possibly renamed) VG again */
 		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid);
 		if (vg_read_error(vg)) {
+			vg_release(vg);
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index c8c4a88..46122d5 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -31,6 +31,7 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 		vg_name = pv_vg_name(pv);
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
+			vg_release(vg);
 		 	log_error("Skipping volume group %s", vg_name);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
 		 	return ECMD_FAILED;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index d288e6f..65b7606 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -387,6 +387,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 
 	vg = _get_vg(cmd, pv_vg_name(pv));
 	if (vg_read_error(vg)) {
+		vg_release(vg);
 		stack;
 		return ECMD_FAILED;
 	}
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 336da9a..bd3cad2 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -37,7 +37,6 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	const char *vg_name;
 	struct lvmcache_info *info;
 	int mda_count = 0;
-	struct volume_group *old_vg = vg;
 
 	dm_list_init(&mdas);
 
@@ -100,7 +99,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 		log_error("%s: Couldn't get size.", pv_name);
 		goto bad;
 	}
-	
+
 	if (new_size) {
 		if (new_size > size)
 			log_warn("WARNING: %s: Overriding real size. "
@@ -127,7 +126,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	if (vg) {
 		pv->size -= pv_pe_start(pv);
 		new_pe_count = pv_size(pv) / vg->extent_size;
-		
+
  		if (!new_pe_count) {
 			log_error("%s: Size must leave space for at "
 				  "least one physical extent of "
@@ -162,8 +161,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 
 bad:
 	unlock_vg(cmd, vg_name);
-	if (!old_vg)
-		vg_release(vg);
+	vg_release(vg);
 	return r;
 }
 
diff --git a/tools/reporter.c b/tools/reporter.c
index d1368d4..1af2adc 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -137,6 +137,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
+			vg_release(vg);
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
diff --git a/tools/toollib.c b/tools/toollib.c
index 1fe9249..248fafb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -354,6 +354,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 
 		vg = vg_read(cmd, vg_name, NULL, 0);
 		if (vg_read_error(vg)) {
+			vg_release(vg);
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 5692582..1000dc2 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -45,6 +45,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	vg = vg_read_for_update(cmd, vg_name, NULL,
 				READ_REQUIRE_RESIZEABLE | LOCK_NONBLOCKING);
 	if (vg_read_error(vg)) {
+		vg_release(vg);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 3ed6c50..006cfdf 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -29,8 +29,10 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);
 	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
-	if (vg_read_error(vg_to))
-		 return ECMD_FAILED;
+	if (vg_read_error(vg_to)) {
+		vg_release(vg_to);
+		return ECMD_FAILED;
+	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 4d115d0..57229e7 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -73,8 +73,10 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	/* FIXME we used to print an error about EXPORTED, but proceeded
 	   nevertheless. */
 	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		vg_release(vg);
 		return_0;
+	}
 
 	if (lvs_in_vg_activated_by_uuid_only(vg)) {
 		unlock_and_release_vg(cmd, vg, vg_name_old);
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 769c5cf..3d42fa1 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -19,6 +19,7 @@ static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
 			 void *handle __attribute((unused)))
 {
+	/* NOTE: vg_unlock_and_release(vg) called from process_each_vg() */
 	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index bd9e8ec..9cd90b8 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -317,8 +317,10 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
 				     READ_REQUIRE_RESIZEABLE);
-	if (vg_read_error(vg_from))
+	if (vg_read_error(vg_from)) {
+		vg_release(vg_from);
 		return ECMD_FAILED;
+	}
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	/*
-- 
1.6.0.6


