From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  7 Oct 2014 14:33:35 +0000 (UTC)
Subject: master - metadata: Fix find_pv_in_vg for missing PVs/filtered devices.
Message-ID: <20141007143335.A6B8560FFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88959032f7efb9229632c74a3738aae171f0c460
Commit:        88959032f7efb9229632c74a3738aae171f0c460
Parent:        0cbb381e159f0606ec749697a596d2a6cc814283
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 7 16:06:21 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 7 16:11:56 2014 +0200

metadata: Fix find_pv_in_vg for missing PVs/filtered devices.

---
 lib/metadata/metadata.c |   35 ++++++++++++-----------------------
 1 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3e5bd5d..5c154bd 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1778,31 +1778,20 @@ struct pv_list *find_pv_in_vg(const struct volume_group *vg,
 			       const char *pv_name)
 {
 	struct pv_list *pvl;
+	struct device *dev = dev_cache_get(pv_name, vg->cmd->filter);
 
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (!pvl->pv->dev) {
-			/*
-			 * pv_dev can't be NULL here!
-			 * We have to catch this situation earlier in the
-			 * code if this internal error is hit. Otherwise,
-			 * there's a possibility that pv_dev will match
-			 * cached_dev in case both are NULL.
-			 *
-			 * NULL cached_dev may happen in case this device
-			 * is filtered and NULL pv_dev may happen if the
-			 * device is missing!
-			 *
-			 * If such incorrect match was hit, simply incorrect
-			 * PV would be processed. This really needs to be
-			 * handled earlier in the code in that case.
-			 */
-			log_error(INTERNAL_ERROR "find_pv_in_vg: PV that is not "
-				  "bound to any existing device found.");
-			return NULL;
-		}
-		if (pvl->pv->dev == dev_cache_get(pv_name, vg->cmd->filter))
+	/*
+	 * If the device does not exist or is filtered out, don't bother trying
+	 * to find it in the list. This also prevents accidentally finding a
+	 * non-NULL PV which happens to be missing (i.e. its pv->dev is NULL)
+	 * for such devices.
+	 */
+	if (!dev)
+		return NULL;
+
+	dm_list_iterate_items(pvl, &vg->pvs)
+		if (pvl->pv->dev == dev)
 			return pvl;
-	}
 
 	return NULL;
 }


