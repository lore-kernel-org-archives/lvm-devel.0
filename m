From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 10 Sep 2020 21:56:17 +0000 (GMT)
Subject: master - lv_manip: relocate check to proper function
Message-ID: <20200910215617.E74A53985444@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc0980362895ab64fb9f11811dc72937fe92c8a7
Commit:        bc0980362895ab64fb9f11811dc72937fe92c8a7
Parent:        e7f5acdfa674af473f31b23413afb1875cb3e078
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 17:39:43 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 23:54:33 2020 +0200

lv_manip: relocate check to proper function

---
 lib/metadata/lv_manip.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ba143075d..e2c0f957b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5068,6 +5068,11 @@ static int _lvresize_check(struct logical_volume *lv,
 	struct volume_group *vg = lv->vg;
 	struct lv_segment *seg = first_seg(lv);
 
+	if (lv_is_writecache(lv)) {
+		log_error("Resize not yet allowed on LVs with writecache attached.");
+		return 0;
+	}
+
 	if (lv_is_external_origin(lv)) {
 		/*
 		 * Since external-origin can be activated read-only,
@@ -5792,11 +5797,6 @@ int lv_resize(struct logical_volume *lv,
 	struct device *dev;
 	char name[PATH_MAX];
 
-	if (lv_is_writecache(lv)) {
-		log_error("Resize not yet allowed on LVs with writecache attached.");
-		return 0;
-	}
-
 	if (!_lvresize_check(lv, lp))
 		return_0;
 


