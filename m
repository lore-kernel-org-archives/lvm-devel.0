From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  7 Oct 2014 07:15:20 +0000 (UTC)
Subject: master - metadata: add internal error if PV has no existing device attached during find_pv_in_vg
Message-ID: <20141007071520.11A9B61447@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=888da17495bc4b8a62833315cf7ad1a0bfd8fe2a
Commit:        888da17495bc4b8a62833315cf7ad1a0bfd8fe2a
Parent:        b66f16fd63014c958d65ab37df4b72f1566176d3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 7 08:58:51 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 7 09:15:12 2014 +0200

metadata: add internal error if PV has no existing device attached during find_pv_in_vg

find_pv_in_vg fn iterates over the list of PVs covered by the VG and
each PV's pvl->pv->dev is compared with device acquired from device
cache. However, in case pvl->pv->dev is NULL as well as device cache
returns NULL (e.g. when device is filtered), we'll get incorrect match
and the code calling find_pv_in_vg uses incorrect PV (as it thinks
it's the exact PV with the pv_name). The INTERNAL_ERROR covers this
situation and errors out immediately.
---
 lib/metadata/metadata.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8443f94..681c2dd 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1778,10 +1778,34 @@ struct pv_list *find_pv_in_vg(const struct volume_group *vg,
 			       const char *pv_name)
 {
 	struct pv_list *pvl;
+	struct device *pv_dev, *cached_dev;
 
-	dm_list_iterate_items(pvl, &vg->pvs)
-		if (pvl->pv->dev == dev_cache_get(pv_name, vg->cmd->filter))
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		pv_dev = pvl->pv->dev;
+		cached_dev = dev_cache_get(pv_name, vg->cmd->filter);
+		if (!pv_dev) {
+			/*
+			 * pv_dev can't be NULL here!
+			 * We have to catch this situation earlier in the
+			 * code if this internal error is hit. Otherwise,
+			 * there's a possibility that pv_dev will match
+			 * cached_dev in case both are NULL.
+			 *
+			 * NULL cached_dev may happen in case this device
+			 * is filtered and NULL pv_dev may happen if the
+			 * device is missing!
+			 *
+			 * If such incorrect match was hit, simply incorrect
+			 * PV would be processed. This really needs to be
+			 * handled earlier in the code in that case.
+			 */
+			log_error(INTERNAL_ERROR "find_pv_in_vg: PV that is not "
+				  "bound to any existing device found");
+			return NULL;
+		}
+		if (pv_dev == cached_dev)
 			return pvl;
+	}
 
 	return NULL;
 }


