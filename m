From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jun 2014 09:24:16 +0000 (UTC)
Subject: master - cleanup: use simplier test
Message-ID: <20140620092416.43F1D6019A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=548269a1ddeb8fa2cfc6a9fd95c5fb2c398914a7
Commit:        548269a1ddeb8fa2cfc6a9fd95c5fb2c398914a7
Parent:        32ad8ab5a4a6cd00f15beb947568a7a5b702f545
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 19 21:08:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 20 11:14:11 2014 +0200

cleanup: use simplier test

Just like all other tests - use direct LV function test
---
 lib/metadata/lv.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index a1211a8..6cbab19 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -776,8 +776,8 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 static int _lv_is_exclusive(struct logical_volume *lv)
 {
-	/* Some devices require exlusivness */
-	return seg_is_raid(first_seg(lv)) ||
+	/* Some devices require exlusiveness */
+	return lv_is_is_raid(lv) ||
 		lv_is_origin(lv) ||
 		lv_is_thin_type(lv) ||
 		lv_is_cache_type(lv);


