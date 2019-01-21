From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:56:07 -0500
Subject: master - vdo: add simple wrapper for getting pool percentage
Message-ID: <201901211156.x0LBu7B9024600@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d367f3348da072360c9dd251d981e627c8444ff
Commit:        3d367f3348da072360c9dd251d981e627c8444ff
Parent:        cbadf3d3704f1153b2919392ab8259b9a798a221
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 21 00:24:30 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

vdo: add simple wrapper for getting pool percentage

Just like with i.e. thins provide simple function for
getting percentage of VDO Pool usage (uses existing
status function).
---
 lib/activate/activate.c |   13 +++++++++++++
 lib/activate/activate.h |    1 +
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 678dec9..072e84e 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1387,6 +1387,19 @@ out:
 	return r;
 }
 
+int lv_vdo_pool_percent(const struct logical_volume *lv, dm_percent_t *percent)
+{
+	struct lv_status_vdo *vdo_status;
+
+	if (!lv_vdo_pool_status(lv, 0, &vdo_status))
+		return_0;
+
+	*percent = vdo_status->usage;
+	dm_pool_destroy(vdo_status->mem);
+
+	return 1;
+}
+
 static int _lv_active(struct cmd_context *cmd, const struct logical_volume *lv)
 {
 	struct lvinfo info;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index aa5410c..dc13f17 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -198,6 +198,7 @@ int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id);
 int lv_vdo_pool_status(const struct logical_volume *lv, int flush,
 		       struct lv_status_vdo **status);
+int lv_vdo_pool_percent(const struct logical_volume *lv, dm_percent_t *percent);
 
 /*
  * Return number of LVs in the VG that are active.


