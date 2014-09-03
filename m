From: David Teigland <teigland@redhat.com>
Date: Wed, 3 Sep 2014 11:49:04 -0500
Subject: [PATCH] vgchange: disallow clustered vg with thin or cache type
Message-ID: <20140903164904.GC20852@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 tools/vgchange.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 88dc180798d2..770fac35ca55 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -304,6 +304,26 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 			       struct volume_group *vg)
 {
 	int clustered = !strcmp(arg_str_value(cmd, clustered_ARG, "n"), "y");
+	struct lv_list *lvl;
+	struct logical_volume *lv;
+
+	if (clustered) {
+		dm_list_iterate_items(lvl, &vg->lvs) {
+			lv = lvl->lv;
+
+			if (lv_is_cache_type(lv)) {
+				log_error("Clustered VG is not supported with cache type LV %s",
+					  lv->name);
+				return 0;
+			}
+
+			if (lv_is_thin_type(lv)) {
+				log_error("Clustered VG is not supported with thin type LV %s",
+					  lv->name);
+				return 0;
+			}
+		}
+	}
 
 	if (clustered && (vg_is_clustered(vg))) {
 		log_error("Volume group \"%s\" is already clustered",
-- 
1.8.3.1


