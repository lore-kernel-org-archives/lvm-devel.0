From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 01:10:09 -0400
Subject: [PATCH v2] Change behavior of tools to make setting the same value return success.
In-Reply-To: <1247115098-11686-1-git-send-email-dwysocha@redhat.com>
References: <1247115098-11686-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1247116210-16571-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Internally the tools were inconsistent.  Some would use log_error() and
then exit with a success code.  However most would use log_error() and
exit with an error code if a user tried to set the value of something
that was already stored.  I believe this is wrong because it is not
what a user would expect normally.  A user (or an application calling
liblvm), would normally expect to get a pass/fail to a set/change
request.  He would not expect to get a failure if the value was in fact
set.  It is much easier to write shell or application code this way
instead of checking for the special case where the value did indeed
get set, but it just so happened it was already stored - most applications
will not care.

To this end, I've modified all the tools to be consistent in this regard.
We now should always use log_print() and exit with a success code if
a user sets a value already stored.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    5 -----
 tools/lvchange.c        |   22 +++++++++++-----------
 tools/lvrename.c        |    4 ++--
 tools/vgchange.c        |   24 ++++++++++++------------
 tools/vgrename.c        |    5 +++++
 5 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 449ac4c..6b42605 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -309,11 +309,6 @@ int validate_vg_rename_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!strcmp(vg_name_old, vg_name_new)) {
-		log_error("Old and new volume group names must differ");
-		return 0;
-	}
-
 	return 1;
 }
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index f64f6d1..6f871cf 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -25,15 +25,15 @@ static int lvchange_permission(struct cmd_context *cmd,
 	lv_access = arg_uint_value(cmd, permission_ARG, 0);
 
 	if ((lv_access & LVM_WRITE) && (lv->status & LVM_WRITE)) {
-		log_error("Logical volume \"%s\" is already writable",
+		log_print("Logical volume \"%s\" is already writable",
 			  lv->name);
-		return 0;
+		return 1;
 	}
 
 	if (!(lv_access & LVM_WRITE) && !(lv->status & LVM_WRITE)) {
-		log_error("Logical volume \"%s\" is already read only",
+		log_print("Logical volume \"%s\" is already read only",
 			  lv->name);
-		return 0;
+		return 1;
 	}
 
 	if ((lv->status & MIRRORED) && (vg_is_clustered(lv->vg)) &&
@@ -329,9 +329,9 @@ static int lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 	alloc = arg_uint_value(cmd, alloc_ARG, alloc);
 
 	if (alloc == lv->alloc) {
-		log_error("Allocation policy of logical volume \"%s\" is "
+		log_print("Allocation policy of logical volume \"%s\" is "
 			  "already %s", lv->name, get_alloc_string(alloc));
-		return 0;
+		return 1;
 	}
 
 	lv->alloc = alloc;
@@ -380,11 +380,11 @@ static int lvchange_readahead(struct cmd_context *cmd,
 
 	if (lv->read_ahead == read_ahead) {
 		if (read_ahead == DM_READ_AHEAD_AUTO)
-			log_error("Read ahead is already auto for \"%s\"", lv->name);
+			log_print("Read ahead is already auto for \"%s\"", lv->name);
 		else
-			log_error("Read ahead is already %u for \"%s\"",
+			log_print("Read ahead is already %u for \"%s\"",
 				  read_ahead, lv->name);
-		return 0;
+		return 1;
 	}
 
 	lv->read_ahead = read_ahead;
@@ -427,9 +427,9 @@ static int lvchange_persistent(struct cmd_context *cmd,
 
 	if (!strcmp(arg_str_value(cmd, persistent_ARG, "n"), "n")) {
 		if (!(lv->status & FIXED_MINOR)) {
-			log_error("Minor number is already not persistent "
+			log_print("Minor number is already not persistent "
 				  "for \"%s\"", lv->name);
-			return 0;
+			return 1;
 		}
 		lv->status &= ~FIXED_MINOR;
 		lv->minor = -1;
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 7411854..61daa32 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -97,8 +97,8 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!strcmp(lv_name_old, lv_name_new)) {
-		log_error("Old and new logical volume names must differ");
-		return EINVALID_CMD_LINE;
+		log_print("Logical volume name already \"%s\"", lv_name_new);
+		return ECMD_PROCESSED;
 	}
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index a5121fc..49f1c86 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -186,9 +186,9 @@ static int _vgchange_alloc(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	if (alloc == vg->alloc) {
-		log_error("Volume group allocation policy is already %s",
+		log_print("Volume group allocation policy is already %s",
 			  get_alloc_string(vg->alloc));
-		return ECMD_FAILED;
+		return ECMD_PROCESSED;
 	}
 
 	if (!archive(vg))
@@ -212,15 +212,15 @@ static int _vgchange_resizeable(struct cmd_context *cmd,
 	int resizeable = !strcmp(arg_str_value(cmd, resizeable_ARG, "n"), "y");
 
 	if (resizeable && (vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" is already resizeable",
+		log_print("Volume group \"%s\" is already resizeable",
 			  vg->name);
-		return ECMD_FAILED;
+		return ECMD_PROCESSED;
 	}
 
 	if (!resizeable && !(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" is already not resizeable",
+		log_print("Volume group \"%s\" is already not resizeable",
 			  vg->name);
-		return ECMD_FAILED;
+		return ECMD_PROCESSED;
 	}
 
 	if (!archive(vg))
@@ -248,15 +248,15 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 	struct lv_list *lvl;
 
 	if (clustered && (vg_is_clustered(vg))) {
-		log_error("Volume group \"%s\" is already clustered",
+		log_print("Volume group \"%s\" is already clustered",
 			  vg->name);
-		return ECMD_FAILED;
+		return ECMD_PROCESSED;
 	}
 
 	if (!clustered && !(vg_is_clustered(vg))) {
-		log_error("Volume group \"%s\" is already not clustered",
+		log_print("Volume group \"%s\" is already not clustered",
 			  vg->name);
-		return ECMD_FAILED;
+		return ECMD_PROCESSED;
 	}
 
 	if (clustered) {
@@ -399,7 +399,7 @@ static int _vgchange_pesize(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	if (extent_size == vg->extent_size) {
-		log_error("Physical extent size of VG %s is already %s",
+		log_print("Physical extent size of VG %s is already %s",
 			  vg->name, display_size(cmd, (uint64_t) extent_size));
 		return ECMD_PROCESSED;
 	}
@@ -516,7 +516,7 @@ static int _vgchange_refresh(struct cmd_context *cmd, struct volume_group *vg)
 
 	if (!vg_refresh_visible(cmd, vg))
 		return ECMD_FAILED;
-	
+
 	return ECMD_PROCESSED;
 }
 
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 57229e7..c6b9880 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -38,6 +38,11 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	if (!validate_vg_rename_params(cmd, vg_name_old, vg_name_new))
 		return 0;
 
+	if (!strcmp(vg_name_old, vg_name_new)) {
+		log_print("Volume group name is already \"%s\"", vg_name_new);
+		return 1;
+	}
+
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
 
 	/* Avoid duplicates */
-- 
1.6.0.6


