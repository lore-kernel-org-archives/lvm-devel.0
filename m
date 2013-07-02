From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:32:35 +0000 (UTC)
Subject: master - metadata: read VG/LV profile name from metadata if it exists and load it
Message-ID: <20130702133235.618F360DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5e6bc393e2d6d8477b115b57697200265aaa595
Commit:        c5e6bc393e2d6d8477b115b57697200265aaa595
Parent:        bfde83eb345621821332a8daeaa3aa6b82da69ea
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:28:36 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:19:09 2013 +0200

metadata: read VG/LV profile name from metadata if it exists and load it

This is per VG/LV profile loading on demand. The profile itself is saved
in struct volume_group/logical_volume as "profile" field so we can
reference it whenever needed.
---
 lib/format_text/import_vsn1.c |   28 ++++++++++++++++++++++++----
 lib/metadata/lv.h             |    1 +
 lib/metadata/vg.h             |    1 +
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 99dd52a..54a4a9c 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -525,7 +525,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 {
 	struct dm_pool *mem = vg->vgmem;
 	struct logical_volume *lv;
-	const char *lv_alloc;
+	const char *str;
 	const struct dm_config_value *cv;
 	const char *hostname;
 	uint64_t timestamp = 0;
@@ -565,14 +565,25 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	}
 
 	lv->alloc = ALLOC_INHERIT;
-	if (dm_config_get_str(lvn, "allocation_policy", &lv_alloc)) {
-		lv->alloc = get_alloc_from_string(lv_alloc);
+	if (dm_config_get_str(lvn, "allocation_policy", &str)) {
+		lv->alloc = get_alloc_from_string(str);
 		if (lv->alloc == ALLOC_INVALID) {
-			log_warn("WARNING: Ignoring unrecognised allocation policy %s for LV %s", lv_alloc, lv->name);
+			log_warn("WARNING: Ignoring unrecognised allocation policy %s for LV %s", str, lv->name);
 			lv->alloc = ALLOC_INHERIT;
 		}
 	}
 
+	if (dm_config_get_str(lvn, "profile", &str)) {
+		log_debug_metadata("Adding profile configuration %s for LV %s/%s.",
+				   str, vg->name, lv->name);
+		lv->profile = add_profile(vg->cmd, str);
+		if (!lv->profile) {
+			log_error("Failed to add configuration profile %s for LV %s/%s",
+				  str, vg->name, lv->name);
+			return 0;
+		}
+	}
+
 	if (!_read_int32(lvn, "read_ahead", &lv->read_ahead))
 		/* If not present, choice of auto or none is configurable */
 		lv->read_ahead = vg->cmd->default_settings.read_ahead;
@@ -789,6 +800,15 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		}
 	}
 
+	if (dm_config_get_str(vgn, "profile", &str)) {
+		log_debug_metadata("Adding profile configuration %s for VG %s.", str, vg->name);
+		vg->profile = add_profile(vg->cmd, str);
+		if (!vg->profile) {
+			log_error("Failed to add configuration profile %s for VG %s", str, vg->name);
+			goto bad;
+		}
+	}
+
 	if (!_read_uint32(vgn, "metadata_copies", &vg->mda_copies)) {
 		vg->mda_copies = DEFAULT_VGMETADATACOPIES;
 	}
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index b1cce51..b123109 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -30,6 +30,7 @@ struct logical_volume {
 
 	uint64_t status;
 	alloc_policy_t alloc;
+	struct profile *profile;
 	uint32_t read_ahead;
 	int32_t major;
 	int32_t minor;
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 0dc3ba7..f33fe11 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -58,6 +58,7 @@ struct volume_group {
 	struct volume_group *vg_ondisk;
 
 	alloc_policy_t alloc;
+	struct profile *profile;
 	uint64_t status;
 
 	struct id id;


