From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 23 Aug 2013 13:49:39 +0000 (UTC)
Subject: master - Thin: Make 'lv_is_on_pv(s)' work with thin types
Message-ID: <20130823134939.3CF1060D2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5c021316843a3b08e4f6d12ec27f06c20ded7da
Commit:        e5c021316843a3b08e4f6d12ec27f06c20ded7da
Parent:        f1e3640df31d0593e47ed82f3bb2f7e976b6569c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Aug 23 08:49:16 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Aug 23 08:49:16 2013 -0500

Thin: Make 'lv_is_on_pv(s)' work with thin types

The pool metadata LV must be accounted for when determining what PVs
are in a thin-pool.  The pool LV must also be accounted for when
checking thin volumes.

This is a prerequisite for pvmove working with thin types.
---
 lib/metadata/lv_manip.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ef64d12..d2830b2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -86,10 +86,18 @@ struct lv_names {
  * (or its metadata device) is on the PV, 1 would be returned for the
  * top-level LV.
  * If you wish to check the images themselves, you should pass them.
+ * Currently handles:
+ *  - linear
+ *  - stripe
+ *  - RAID
+ *  - mirror
+ *  - thin-pool
+ *  - thin
  *
  * FIXME:  This should be made more generic, possibly use 'for_each_sub_lv'.
  * 'for_each_sub_lv' does not yet allow us to short-circuit execution or
- * pass back the values we need yet though...
+ * pass back the values we need yet though (i.e. it only allows success or
+ * error - not true or false).
  *
  * Returns: 1 if LV (or part of LV) is on PV, 0 otherwise
  */
@@ -110,6 +118,20 @@ int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
 	if (lv_is_on_pv(seg->log_lv, pv))
 		return 1;
 
+	/* Check thin-pool metadata area */
+	if (lv_is_on_pv(seg->metadata_lv, pv))
+		return 1;
+
+	/* Check thin volume's pool LV */
+	if (lv_is_on_pv(seg->pool_lv, pv))
+		return 1;
+
+	/*
+	 * Do _not_ check 'external_lv.  We wouldn't count an origin's
+	 * PVs as part of a snapshot, so we don't count external_origin's
+	 * PVs as part of a thin-snap/LV
+	 */
+
 	/* Check stack of LVs */
 	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {


