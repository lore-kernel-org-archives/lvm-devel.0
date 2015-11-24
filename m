From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 24 Nov 2015 10:33:23 +0000 (UTC)
Subject: master - cleanup: use display_lvname
Message-ID: <20151124103323.87E3E60DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9243877ea10f46163506dc64d073d1f24446ab24
Commit:        9243877ea10f46163506dc64d073d1f24446ab24
Parent:        5e50e5f0b4074bbeb093f1fba334076be3f59f3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 22 23:03:01 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 23 23:42:59 2015 +0100

cleanup: use display_lvname

Switch debug msg to use display_lvname.
Link to VG early, so we have access to VG from LV.
---
 lib/format_text/import_vsn1.c |   55 +++++++++++++++++++++--------------------
 1 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index d63192e..879aae7 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -563,6 +563,9 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	if (!(lv = alloc_lv(mem)))
 		return_0;
 
+	if (!link_lv_to_vg(vg, lv))
+		return_0;
+
 	if (!(lv->name = dm_pool_strdup(mem, lvn->key)))
 		return_0;
 
@@ -573,7 +576,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 
 	if (!_read_flag_config(lvn, &lvstatus, LV_FLAGS)) {
 		log_error("Couldn't read status flags for logical volume %s.",
-			  lv->name);
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -586,17 +589,17 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	if (dm_config_has_node(lvn, "creation_time")) {
 		if (!_read_uint64(lvn, "creation_time", &timestamp)) {
 			log_error("Invalid creation_time for logical volume %s.",
-				  lv->name);
+				  display_lvname(lv));
 			return 0;
 		}
 		if (!dm_config_get_str(lvn, "creation_host", &hostname)) {
 			log_error("Couldn't read creation_host for logical volume %s.",
-				  lv->name);
+				  display_lvname(lv));
 			return 0;
 		}
 	} else if (dm_config_has_node(lvn, "creation_host")) {
 		log_error("Missing creation_time for logical volume %s.",
-			  lv->name);
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -624,22 +627,22 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 			return_0;
 	}
 
-	lv->alloc = ALLOC_INHERIT;
 	if (dm_config_get_str(lvn, "allocation_policy", &str)) {
 		lv->alloc = get_alloc_from_string(str);
 		if (lv->alloc == ALLOC_INVALID) {
-			log_warn("WARNING: Ignoring unrecognised allocation policy %s for LV %s", str, lv->name);
+			log_warn("WARNING: Ignoring unrecognised allocation policy %s for LV %s.",
+				 str, display_lvname(lv));
 			lv->alloc = ALLOC_INHERIT;
 		}
-	}
+	} else
+		lv->alloc = ALLOC_INHERIT;
 
 	if (dm_config_get_str(lvn, "profile", &str)) {
-		log_debug_metadata("Adding profile configuration %s for LV %s/%s.",
-				   str, vg->name, lv->name);
-		lv->profile = add_profile(vg->cmd, str, CONFIG_PROFILE_METADATA);
-		if (!lv->profile) {
-			log_error("Failed to add configuration profile %s for LV %s/%s",
-				  str, vg->name, lv->name);
+		log_debug_metadata("Adding profile configuration %s for LV %s.",
+				   str, display_lvname(lv));
+		if (!(lv->profile = add_profile(vg->cmd, str, CONFIG_PROFILE_METADATA))) {
+			log_error("Failed to add configuration profile %s for LV %s.",
+				  str, display_lvname(lv));
 			return 0;
 		}
 	}
@@ -652,7 +655,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 		case 0:
 			lv->read_ahead = DM_READ_AHEAD_AUTO;
 			break;
-		case (uint32_t) -1:
+		case UINT32_C(-1):
 			lv->read_ahead = DM_READ_AHEAD_NONE;
 			break;
 		default:
@@ -663,34 +666,32 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	/* Optional tags */
 	if (dm_config_get_list(lvn, "tags", &cv) &&
 	    !(_read_str_list(mem, &lv->tags, cv))) {
-		log_error("Couldn't read tags for logical volume %s/%s.",
-			  vg->name, lv->name);
+		log_error("Couldn't read tags for logical volume %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (!dm_hash_insert(lv_hash, lv->name, lv))
 		return_0;
 
-	if (!link_lv_to_vg(vg, lv))
-		return_0;
-
 	if (timestamp && !lv_set_creation(lv, hostname, timestamp))
 		return_0;
 
 	if (!lv_is_visible(lv) && strstr(lv->name, "_pmspare")) {
 		if (vg->pool_metadata_spare_lv) {
 			log_error("Couldn't use another pool metadata spare "
-				  "logical volume %s/%s.", vg->name, lv->name);
+				  "logical volume %s.", display_lvname(lv));
 			return 0;
 		}
 		log_debug_metadata("Logical volume %s is pool metadata spare.",
-				   lv->name);
+				   display_lvname(lv));
 		lv->status |= POOL_METADATA_SPARE;
 		vg->pool_metadata_spare_lv = lv;
 	}
 
 	if (!lv_is_visible(lv) && !strcmp(lv->name, LOCKD_SANLOCK_LV_NAME)) {
-		log_debug_metadata("Logical volume %s is sanlock lv.", lv->name);
+		log_debug_metadata("Logical volume %s is sanlock lv.",
+				   display_lvname(lv));
 		lv->status |= LOCKD_SANLOCK_LV;
 		vg->sanlock_lv = lv;
 	}
@@ -721,7 +722,7 @@ static int _read_lvsegs(struct format_instance *fid,
 	/* FIXME: read full lvid */
 	if (!_read_id(&lv->lvid.id[1], lvn, "id")) {
 		log_error("Couldn't read uuid for logical volume %s.",
-			  lv->name);
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -736,8 +737,8 @@ static int _read_lvsegs(struct format_instance *fid,
 
 	if (lv->status & FIXED_MINOR) {
 		if (!_read_int32(lvn, "minor", &lv->minor)) {
-			log_error("Couldn't read minor number for logical "
-				  "volume %s.", lv->name);
+			log_error("Couldn't read minor number for logical volume %s.",
+				  display_lvname(lv));
 			return 0;
 		}
 
@@ -746,13 +747,13 @@ static int _read_lvsegs(struct format_instance *fid,
 			lv->major = vg->cmd->dev_types->device_mapper_major;
 		else if (!_read_int32(lvn, "major", &lv->major)) {
 			log_warn("WARNING: Couldn't read major number for logical "
-				 "volume %s.", lv->name);
+				 "volume %s.", display_lvname(lv));
 			lv->major = vg->cmd->dev_types->device_mapper_major;
 		}
 
 		if (!validate_major_minor(vg->cmd, fid->fmt, lv->major, lv->minor)) {
 			log_warn("WARNING: Ignoring invalid major, minor number for "
-				 "logical volume %s.", lv->name);
+				 "logical volume %s.", display_lvname(lv));
 			lv->major = lv->minor = -1;
 		}
 	}


