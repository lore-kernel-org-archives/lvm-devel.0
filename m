From: David Teigland <teigland@sourceware.org>
Date: Wed, 12 Jul 2017 11:55:08 -0400
Subject: master - pvs: use dummy structs in duplicate processing
Message-ID: <201707121555.v6CFt8JU020519@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e329da173f51c6b1c2af1fc144a52a740955f445
Commit:        e329da173f51c6b1c2af1fc144a52a740955f445
Parent:        c4b6df94b4a39335369c439eb3110a06649378e5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 12 10:51:54 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 12 10:51:54 2017 -0500

pvs: use dummy structs in duplicate processing

Use the same dummy struct approach from report.c
when a pv needs to be processed without a real vg.
---
 tools/toollib.c |   50 ++++++++++++++++++++++++++++++++------------------
 1 files changed, 32 insertions(+), 18 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 452c8b0..2836aeb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4024,18 +4024,36 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 				  struct processing_handle *handle,
 				  process_single_pv_fn_t process_single_pv)
 {
-	struct physical_volume pv_dummy;
-	struct physical_volume *pv;
 	struct device_id_list *dil;
 	struct device_list *devl;
 	struct dm_list unused_duplicate_devs;
 	struct lvmcache_info *info;
-	struct volume_group *vg = NULL;
-	const char *vgname = NULL;
-	const char *vgid = NULL;
+	const char *vgname;
+	const char *vgid;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
+	struct physical_volume dummy_pv = {
+		.tags = DM_LIST_HEAD_INIT(dummy_pv.tags),
+		.segments= DM_LIST_HEAD_INIT(dummy_pv.segments),
+	};
+
+	struct format_instance dummy_fid = {
+		.metadata_areas_in_use = DM_LIST_HEAD_INIT(dummy_fid.metadata_areas_in_use),
+		.metadata_areas_ignored = DM_LIST_HEAD_INIT(dummy_fid.metadata_areas_ignored),
+	};
+
+	struct volume_group dummy_vg = {
+		.fid = &dummy_fid,
+		.name = "",
+		.system_id = (char *) "",
+		.lvm1_system_id = (char *) "",
+		.pvs = DM_LIST_HEAD_INIT(dummy_vg.pvs),
+		.lvs = DM_LIST_HEAD_INIT(dummy_vg.lvs),
+		.historical_lvs = DM_LIST_HEAD_INIT(dummy_vg.historical_lvs),
+		.tags = DM_LIST_HEAD_INIT(dummy_vg.tags),
+	};
+
 	dm_list_init(&unused_duplicate_devs);
 
 	if (!lvmcache_get_unused_duplicate_devs(cmd, &unused_duplicate_devs))
@@ -4085,22 +4103,18 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 		}
 
 		vgname = lvmcache_vgname_from_info(info);
-		if (vgname)
-			vgid = lvmcache_vgid_from_vgname(cmd, vgname);
-		if (vgid)
-			vg = lvmcache_get_vg(cmd, vgname, vgid, 0);
+		vgid = vgname ? lvmcache_vgid_from_vgname(cmd, vgname) : NULL;
 
-		memset(&pv_dummy, 0, sizeof(pv_dummy));
-		dm_list_init(&pv_dummy.tags);
-		dm_list_init(&pv_dummy.segments);
-		pv_dummy.dev = devl->dev;
-		pv_dummy.fmt = lvmcache_fmt_from_info(info);
-		pv = &pv_dummy;
+		dummy_pv.dev = devl->dev;
+		dummy_pv.fmt = lvmcache_fmt_from_info(info);
+		dummy_vg.name = vgname ?: "";
 
-		ret = process_single_pv(cmd, vg, pv, handle);
+		if (vgid)
+			memcpy(&dummy_vg.id, vgid, ID_LEN);
+		else
+			memset(&dummy_vg.id, 0, sizeof(dummy_vg.id));
 
-		if (vg)
-			release_vg(vg);
+		ret = process_single_pv(cmd, &dummy_vg, &dummy_pv, handle);
 
 		if (ret > ret_max)
 			ret_max = ret;


