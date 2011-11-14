From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Nov 2011 16:12:57 -0500
Subject: [PATCH 1/5] Add static _check_pv_sizes() function to check all pv sizes for consistency.
In-Reply-To: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
References: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1321305181-28158-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This function checks for the underlying device size < pv_size, and returns
0 (fail) if such a PV is found.  It should always be the case that the device
size >= pv_size (recorded at pvcreate time).  Before this patch, LVM does
not detect if the underlying device changes in size (for example, the PV
is a LUN on a SAN, and gets resized) after pvcreate initialization.

This function should be called from vg_validate() and vg_read_internal() at
the very least, barring some condition I have not thought of.  Whether
we want to warn or error out at those points is somewhat up for discussion
(see later patches).

We could also just call this only from a check/repair code path such as
pvck and/or vgck code path.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4037c0e..3ee39f7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2302,6 +2302,34 @@ static int _lv_validate_references_single(struct logical_volume *lv, void *data)
 	return r;
 }
 
+/*
+ * Check all pv sizes for consistency.
+ * It should never be the case that the device size is less than the pv_size.
+ * This can happen if for example, the PVs are on a SAN and they get resized.
+ * Often resizes are done and it is assumed subsystems such as LVM
+ * automatically detect the changes.
+ */
+static int _check_pv_sizes(struct volume_group *vg)
+{
+	struct physical_volume *pv;
+	struct pv_list *pvl;
+	int ret=1;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		pv = pvl->pv;
+		if (is_missing_pv(pv))
+			continue;
+
+		if (pv_dev_size(pv) < pv_size(pv)) {
+			log_error("Device %s size = %lu smaller than "
+				  "pv_size = %lu.  Was device resized?\n",
+				  pv_dev_name(pv), pv_dev_size(pv), pv_size(pv));
+			ret = 0;
+		}
+	}
+	return ret;
+}
+
 int vg_validate(struct volume_group *vg)
 {
 	struct pv_list *pvl;
-- 
1.7.4.4


