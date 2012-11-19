From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Nov 2012 13:48:55 +0000 (UTC)
Subject: master - liblvm: internal API change
Message-ID: <20121119134855.D4FCA1698@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e96ea4a899a0d0a5adb5e3d8fa09e04fd7a4173
Commit:        2e96ea4a899a0d0a5adb5e3d8fa09e04fd7a4173
Parent:        cf5242a670010a7c0137090a330b78b3bf43a55b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 13 10:49:32 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 14:37:30 2012 +0100

liblvm: internal API change

Return LV/NULL instead of 1/0 which saves lookup for created LV.
---
 lib/metadata/lv_manip.c          |    6 +++---
 lib/metadata/metadata-exported.h |    4 ++--
 liblvm/lvm_lv.c                  |    8 +++-----
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9f87854..dc315ac 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4714,8 +4714,8 @@ revert_new_lv:
 	return NULL;
 }
 
-int lv_create_single(struct volume_group *vg,
-		     struct lvcreate_params *lp)
+struct logical_volume *lv_create_single(struct volume_group *vg,
+					struct lvcreate_params *lp)
 {
 	struct logical_volume *lv;
 
@@ -4743,5 +4743,5 @@ int lv_create_single(struct volume_group *vg,
 out:
 	log_print_unless_silent("Logical volume \"%s\" created", lv->name);
 
-	return 1;
+	return lv;
 }
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b586936..ffec129 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -626,8 +626,8 @@ struct lvcreate_params {
 	struct dm_list tags;	/* all */
 };
 
-int lv_create_single(struct volume_group *vg,
-		     struct lvcreate_params *lp);
+struct logical_volume *lv_create_single(struct volume_group *vg,
+					struct lvcreate_params *lp);
 
 /*
  * Functions for layer manipulation
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index d47a857..77bdebf 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -146,7 +146,7 @@ lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 {
 	struct lvcreate_params lp = { 0 };
 	uint64_t extents;
-	struct lv_list *lvl;
+	struct logival_volume *lv;
 
 	if (vg_read_error(vg))
 		return NULL;
@@ -162,11 +162,9 @@ lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 	_lv_set_default_params(&lp, vg, name, extents);
 	if (!_lv_set_default_linear_params(vg->cmd, &lp))
 		return_NULL;
-	if (!lv_create_single(vg, &lp))
+	if (!(lv = lv_create_single(vg, &lp)))
 		return_NULL;
-	if (!(lvl = find_lv_in_vg(vg, name)))
-		return NULL;
-	return (lv_t) lvl->lv;
+	return (lv_t) lv;
 }
 
 /*


