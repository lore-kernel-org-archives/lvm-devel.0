From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:48 +0000 (GMT)
Subject: main - cov: defined flv
Message-ID: <20210310003648.012F13858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94712e3233ac7610ed74c3207c131ec7d9a843c1
Commit:        94712e3233ac7610ed74c3207c131ec7d9a843c1
Parent:        a66380ea3ebcdb21e5b63f5991810e421092b245
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 16:42:38 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:35:02 2021 +0100

cov: defined flv

---
 lib/activate/activate.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ddad7c3f7..c450eab14 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2846,7 +2846,7 @@ static int _deactivate_sub_lv_cb(struct logical_volume *lv, void *data)
  */
 int deactivate_lv_with_sub_lv(const struct logical_volume *lv)
 {
-	struct logical_volume *flv;
+	struct logical_volume *flv = NULL;
 
 	if (!deactivate_lv(lv->vg->cmd, lv)) {
 		log_error("Cannot deactivate logical volume %s.",
@@ -2856,7 +2856,7 @@ int deactivate_lv_with_sub_lv(const struct logical_volume *lv)
 
 	if (!for_each_sub_lv((struct logical_volume *)lv, _deactivate_sub_lv_cb, &flv)) {
 		log_error("Cannot deactivate subvolume %s of logical volume %s.",
-			  display_lvname(flv), display_lvname(lv));
+			  (flv) ? display_lvname(flv) : "", display_lvname(lv));
 		return 0;
 	}
 


