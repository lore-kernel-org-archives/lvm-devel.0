From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:21 -0400
Subject: master - cachevol: drop LV_CACHE_VOL on detach automatically
Message-ID: <201910141322.x9EDMLU5018785@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=77deadd3af81d5641e2e53e604efbfab2cb6d330
Commit:        77deadd3af81d5641e2e53e604efbfab2cb6d330
Parent:        8a8e6ebba2521da596e9e85fe2799e336640ace3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 14 10:45:10 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:15:14 2019 +0200

cachevol: drop LV_CACHE_VOL on detach automatically

Move dropping of cachevol flag into detach function.
TODO: this flag should be internal to lvm2.
---
 lib/metadata/pool_manip.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 934bb56..b9d04ea 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -254,6 +254,7 @@ int detach_pool_lv(struct lv_segment *seg)
 			return_0;
 		seg->lv->status &= ~CACHE;
 		lv_set_visible(seg->pool_lv);
+		seg->pool_lv->status &= ~LV_CACHE_VOL;
 		seg->pool_lv = NULL;
 		return 1;
 	}


