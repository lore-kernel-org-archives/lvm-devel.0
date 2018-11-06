From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:43:10 -0500
Subject: master - cache: improve error message about flush
Message-ID: <201811062143.wA6LhAcQ004783@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=23948e99b3d723f09456f75c93655817f87f1a82
Commit:        23948e99b3d723f09456f75c93655817f87f1a82
Parent:        3e547fa9528e119205fcf182aecccd49c3695547
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 16:10:49 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:29 2018 -0600

cache: improve error message about flush

---
 lib/metadata/cache_manip.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 6b87873..66f759f 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -608,8 +608,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 			cache_lv->status |= LV_TEMPORARY;
 			if (!activate_lv(cache_lv->vg->cmd, cache_lv) ||
 			    !lv_is_active(cache_lv)) {
-				log_error("Failed to active cache locally %s.",
-					  display_lvname(cache_lv));
+				log_error("Failed to activate %s to flush cache.", display_lvname(cache_lv));
 				return 0;
 			}
 			cache_lv->status &= ~LV_TEMPORARY;


