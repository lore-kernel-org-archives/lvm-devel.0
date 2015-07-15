From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Jul 2015 11:10:48 +0000 (UTC)
Subject: master - cache: move setting of cache policy
Message-ID: <20150715111048.CB5FD609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86a4d47215570517804fa0e7acedf8d0473c5e07
Commit:        86a4d47215570517804fa0e7acedf8d0473c5e07
Parent:        4a33d5714341caf281f8e519b4b6c875d6eba292
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 14 09:57:34 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 15 13:10:21 2015 +0200

cache: move setting of cache policy

Set policy before saving 1st. metadata and avoid unnecessary reload.
Fixes problem when we stored cache-pool without cache-policy set.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    9 ++-------
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3a8cd9e..ca50a1e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.126 -
 ================================
+  Set cache policy before with the first lvm2 cache pool metadata commit.
   Fix detection of thin-pool overprovisioning (2.02.124).
   Fix lvmpolld segfaults on 32 bit architectures.
   Fix ignored --startstopservices option if running lvmconf with systemd.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9decf32..b2e5601 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7245,6 +7245,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (seg_is_cache_pool(lp) || seg_is_cache(lp)) {
 		pool_lv = pool_lv ? : lv;
+		if (!lv_cache_setpolicy(pool_lv, lp->cache_policy))
+			return_NULL; /* revert? */
 		first_seg(pool_lv)->chunk_size = lp->chunk_size;
 		first_seg(pool_lv)->feature_flags = lp->feature_flags;
 		/* TODO: some calc_policy solution for cache ? */
@@ -7437,13 +7439,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 	}
 
-	if (lv_is_cache_pool(lv) && !origin_lv) {
-		if (lp->cache_policy && !lv_cache_setpolicy(lv, lp->cache_policy))
-			return NULL; /* revert? */
-		if (!lv_update_and_reload(lv))
-			return NULL; /* FIXME: revert */
-	}
-
 	if (seg_is_cache(lp) || (origin_lv && lv_is_cache_pool(lv))) {
 		/* Finish cache conversion magic */
 		if (origin_lv) {


