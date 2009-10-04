From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:38 -0400
Subject: [PATCH 01/10] Refactor vg_extend - add vg_extend_single_pv.
In-Reply-To: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1254697907-16448-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Simple refactor to setup future changes related to implicit pvcreates.
Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 263c705..07af5b1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -553,22 +553,38 @@ int vg_remove(struct volume_group *vg)
 	return ret;
 }
 
+/*
+ * Extend a VG by a single PV / device path
+ *
+ * Parameters:
+ * - vg: handle of volume group to extend by 'pv_name'
+ * - pv_name: device path of PV to add to VG
+ *
+ */
+static int vg_extend_single_pv(struct volume_group *vg, char *pv_name)
+{
+	struct physical_volume *pv;
+
+	if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_name))) {
+		log_error("%s not identified as an existing "
+			  "physical volume", pv_name);
+		return 0;
+	}
+	if (!add_pv_to_vg(vg, pv_name, pv))
+		return 0;
+	return 1;
+}
+
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 {
 	int i;
-	struct physical_volume *pv;
 
 	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
 		return 0;
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
-		if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_names[i]))) {
-			log_error("%s not identified as an existing "
-				  "physical volume", pv_names[i]);
-			goto bad;
-		}
-		if (!add_pv_to_vg(vg, pv_names[i], pv))
+		if (!vg_extend_single_pv(vg, pv_names[i]))
 			goto bad;
 	}
 
-- 
1.6.0.6


