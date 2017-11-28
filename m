From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 27 Nov 2017 20:37:52 -0500
Subject: master - label: Remove unused verify functions.
Message-ID: <201711280137.vAS1bqoW024950@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9812ec9d3469edbe24a2d08ccb1dda209cf66a5
Commit:        a9812ec9d3469edbe24a2d08ccb1dda209cf66a5
Parent:        02e934c444d2e292123fa3caff3197b84671d340
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Nov 28 01:36:55 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Nov 28 01:36:55 2017 +0000

label: Remove unused verify functions.

label_verify has never been used so remove it.
---
 WHATS_NEW                    |    1 +
 lib/format1/lvm1-label.c     |    1 -
 lib/format_pool/pool_label.c |    1 -
 lib/format_text/text_label.c |    1 -
 lib/label/label.c            |   27 ---------------------------
 lib/label/label.h            |    6 ------
 6 files changed, 1 insertions(+), 36 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5937bad..4ff8dcb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Remove label_verify that has never been used.
   Ensure very large numbers used as arguments are not casted to lower values. 
   Enhance reading and validation of options stripes and stripes_size.
   Fix printing of default stripe size when user is not using stripes.
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index f5ce1e8..3b8a655 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -109,7 +109,6 @@ struct label_ops _lvm1_ops = {
 	.can_handle = _lvm1_can_handle,
 	.write = _lvm1_write,
 	.read = _lvm1_read,
-	.verify = _lvm1_can_handle,
 	.initialise_label = _lvm1_initialise_label,
 	.destroy_label = _lvm1_destroy_label,
 	.destroy = _lvm1_destroy,
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
index 0f1d1f7..2e30a7b 100644
--- a/lib/format_pool/pool_label.c
+++ b/lib/format_pool/pool_label.c
@@ -83,7 +83,6 @@ struct label_ops _pool_ops = {
       .can_handle = _pool_can_handle,
       .write = _pool_write,
       .read = _pool_read,
-      .verify = _pool_can_handle,
       .initialise_label = _pool_initialise_label,
       .destroy_label = _pool_destroy_label,
       .destroy = _label_pool_destroy,
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index ad323b6..6d9cfbd 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -464,7 +464,6 @@ struct label_ops _text_ops = {
 	.can_handle = _text_can_handle,
 	.write = _text_write,
 	.read = _text_read,
-	.verify = _text_can_handle,
 	.initialise_label = _text_initialise_label,
 	.destroy_label = _text_destroy_label,
 	.destroy = _fmt_text_destroy,
diff --git a/lib/label/label.c b/lib/label/label.c
index 0e99517..7a7c500 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -353,33 +353,6 @@ int label_write(struct device *dev, struct label *label)
 	return r;
 }
 
-/* Unused */
-int label_verify(struct device *dev)
-{
-	struct labeller *l;
-	char buf[LABEL_SIZE] __attribute__((aligned(8)));
-	uint64_t sector;
-	struct lvmcache_info *info;
-	int r = 0;
-
-	if (!dev_open_readonly(dev)) {
-		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
-			_update_lvmcache_orphan(info);
-		return_0;
-	}
-
-	if (!(l = _find_labeller(dev, buf, &sector, UINT64_C(0))))
-		goto out;
-
-	r = l->ops->verify ? l->ops->verify(l, buf, sector) : 1;
-
-      out:
-	if (!dev_close(dev))
-		stack;
-
-	return r;
-}
-
 void label_destroy(struct label *label)
 {
 	label->labeller->ops->destroy_label(label->labeller, label);
diff --git a/lib/label/label.h b/lib/label/label.h
index cd6e5b7..ea11290 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -66,11 +66,6 @@ struct label_ops {
 		     void *buf, struct label ** label);
 
 	/*
-	 * Additional consistency checks for the paranoid.
-	 */
-	int (*verify) (struct labeller * l, void *buf, uint64_t sector);
-
-	/*
 	 * Populate label_type etc.
 	 */
 	int (*initialise_label) (struct labeller * l, struct label * label);
@@ -102,7 +97,6 @@ int label_remove(struct device *dev);
 int label_read(struct device *dev, struct label **result,
 		uint64_t scan_sector);
 int label_write(struct device *dev, struct label *label);
-int label_verify(struct device *dev);
 struct label *label_create(struct labeller *labeller);
 void label_destroy(struct label *label);
 


