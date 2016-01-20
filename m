From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 20 Jan 2016 00:59:25 +0000 (UTC)
Subject: master - activation: Add lv_is_active_remotely.
Message-ID: <20160120005925.32C6C60C87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2304286f68debd4755b44fa8b779b762142bfada
Commit:        2304286f68debd4755b44fa8b779b762142bfada
Parent:        c812c2dbc7ced09a715e5689f941ba255821f0bc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 19 22:01:59 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 19 22:01:59 2016 +0000

activation: Add lv_is_active_remotely.

---
 lib/activate/activate.c |   49 +++++++++++++++++++++++++++++++++++-----------
 1 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4cd268e..aa24a5f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -389,6 +389,10 @@ int lv_is_active_locally(const struct logical_volume *lv)
 {
 	return 0;
 }
+int lv_is_active_remotely(const struct logical_volume *lv)
+{
+	return 0;
+}
 int lv_is_active_but_not_locally(const struct logical_volume *lv)
 {
 	return 0;
@@ -1334,12 +1338,14 @@ int lvs_in_vg_opened(const struct volume_group *vg)
  * _lv_is_active
  * @lv:        logical volume being queried
  * @locally:   set if active locally (when provided)
+ * @remotely:  set if active remotely (when provided)
  * @exclusive: set if active exclusively (when provided)
  *
  * Determine whether an LV is active locally or in a cluster.
  * In addition to the return code which indicates whether or
  * not the LV is active somewhere, two other values are set
  * to yield more information about the status of the activation:
+ *
  *	return	locally	exclusively	status
  *	======	=======	===========	======
  *	   0	   0	    0		not active
@@ -1352,9 +1358,10 @@ int lvs_in_vg_opened(const struct volume_group *vg)
  * Returns: 0 or 1
  */
 static int _lv_is_active(const struct logical_volume *lv,
-			 int *locally, int *exclusive)
+			 int *locally, int *remotely, int *exclusive)
 {
 	int r, l, e; /* remote, local, and exclusive */
+	int skip_cluster_query = 0;
 
 	r = l = e = 0;
 
@@ -1367,11 +1374,14 @@ static int _lv_is_active(const struct logical_volume *lv,
 		goto out;
 	}
 
-	/* Active locally, and the caller doesn't care about exclusive */
-	if (l && !exclusive)
+	/* Active locally, and the caller doesn't care about exclusive or remotely */
+	if (l && !exclusive && !remotely)
+		skip_cluster_query = 1;
+
+	if (skip_cluster_query)
 		goto out;
 
-	if ((r = cluster_lock_held(lv->lvid.s, "", &e)) >= 0)
+	if ((r = cluster_lock_held(lv->lvid.s, NODE_REMOTE, &e)) >= 0)
 		goto out;
 
 	/*
@@ -1387,6 +1397,9 @@ static int _lv_is_active(const struct logical_volume *lv,
 
 	e = 0;
 
+	/* Also set remotely as a precaution, as we don't know */
+	r = 1;
+
 	/*
 	 * We used to attempt activate_lv_excl_local(lv->vg->cmd, lv) here,
 	 * but it's unreliable.
@@ -1397,53 +1410,65 @@ out:
 		*locally = l;
 	if (exclusive)
 		*exclusive = e;
+	if (remotely)
+		*remotely = r;
 
-	log_very_verbose("%s is %sactive%s%s",
+	log_very_verbose("%s is %sactive%s%s%s%s",
 			 display_lvname(lv),
 			 (r || l) ? "" : "not ",
 			 (exclusive && e) ? " exclusive" : "",
-			 e ? (l ? " locally" : " remotely") : "");
+			 l ? " locally" : "",
+			 (!skip_cluster_query && l && r) ? " and" : "",
+			 (!skip_cluster_query && r) ? " remotely" : "");
 
 	return r || l;
 }
 
 int lv_is_active(const struct logical_volume *lv)
 {
-	return _lv_is_active(lv, NULL, NULL);
+	return _lv_is_active(lv, NULL, NULL, NULL);
 }
 
 int lv_is_active_locally(const struct logical_volume *lv)
 {
 	int l;
 
-	return _lv_is_active(lv, &l, NULL) && l;
+	return _lv_is_active(lv, &l, NULL, NULL) && l;
+}
+
+int lv_is_active_remotely(const struct logical_volume *lv)
+{
+	int r;
+
+	return _lv_is_active(lv, NULL, &r, NULL) && r;
 }
 
 int lv_is_active_but_not_locally(const struct logical_volume *lv)
 {
 	int l;
-	return _lv_is_active(lv, &l, NULL) && !l;
+
+	return _lv_is_active(lv, &l, NULL, NULL) && !l;
 }
 
 int lv_is_active_exclusive(const struct logical_volume *lv)
 {
 	int e;
 
-	return _lv_is_active(lv, NULL, &e) && e;
+	return _lv_is_active(lv, NULL, NULL, &e) && e;
 }
 
 int lv_is_active_exclusive_locally(const struct logical_volume *lv)
 {
 	int l, e;
 
-	return _lv_is_active(lv, &l, &e) && l && e;
+	return _lv_is_active(lv, &l, NULL, &e) && l && e;
 }
 
 int lv_is_active_exclusive_remotely(const struct logical_volume *lv)
 {
 	int l, e;
 
-	return _lv_is_active(lv, &l, &e) && !l && e;
+	return _lv_is_active(lv, &l, NULL, &e) && !l && e;
 }
 
 #ifdef DMEVENTD


