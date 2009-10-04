From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:39 -0400
Subject: [PATCH 02/10] Add pvcreate_params to vg_extend_single_pv.
In-Reply-To: <1254697907-16448-2-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1254697907-16448-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.  If this parameter is set to NULL, just fail
the extend if the device is not already a PV.  If non-NULL, try pvcreate_single
before failing.  Note that pvcreate_single() handles the log_error in case
of failure so we just return 0 if pvcreate_single() fails.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 07af5b1..b6f84d7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -559,16 +559,23 @@ int vg_remove(struct volume_group *vg)
  * Parameters:
  * - vg: handle of volume group to extend by 'pv_name'
  * - pv_name: device path of PV to add to VG
+ * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
  *
  */
-static int vg_extend_single_pv(struct volume_group *vg, char *pv_name)
+static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
+			       struct pvcreate_params *pp)
 {
 	struct physical_volume *pv;
 
-	if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_name))) {
+	pv = pv_by_path(vg->fid->fmt->cmd, pv_name);
+	if (!pv && !pp) {
 		log_error("%s not identified as an existing "
 			  "physical volume", pv_name);
 		return 0;
+	} else if (!pv && pp) {
+		pv = pvcreate_single(vg->cmd, pv_name, pp);
+		if (!pv)
+			return 0;
 	}
 	if (!add_pv_to_vg(vg, pv_name, pv))
 		return 0;
@@ -584,7 +591,7 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
-		if (!vg_extend_single_pv(vg, pv_names[i]))
+		if (!vg_extend_single_pv(vg, pv_names[i], NULL))
 			goto bad;
 	}
 
-- 
1.6.0.6


