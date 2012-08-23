From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:43:10 +0000 (UTC)
Subject: master - lvmapi: validate extents size for lvcreate
Message-ID: <20120823124310.819AAA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0de57b98bf0778684e8fac6d2d66ecf3fbc035ab
Commit:        0de57b98bf0778684e8fac6d2d66ecf3fbc035ab
Parent:        eb08f8652125513761e83c324a2c7e706ccda791
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 1 17:59:35 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:38:48 2012 +0200

lvmapi: validate extents size for lvcreate

---
 liblvm/lvm_lv.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 23ccbe8..2d4dc02 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -153,15 +153,18 @@ lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 	if (!vg_check_write_mode(vg))
 		return NULL;
 
-	extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
-				    vg->extent_size);
+	if (!(extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
+					  vg->extent_size))) {
+		log_error("Unable to create LV without size.");
+		return NULL;
+	}
+
 	_lv_set_default_params(&lp, vg, name, extents);
 	if (!_lv_set_default_linear_params(vg->cmd, &lp))
 		return_NULL;
 	if (!lv_create_single(vg, &lp))
-		return NULL;
-	lvl = find_lv_in_vg(vg, name);
-	if (!lvl)
+		return_NULL;
+	if (!(lvl = find_lv_in_vg(vg, name)))
 		return NULL;
 	return (lv_t) lvl->lv;
 }


