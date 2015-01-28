From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 28 Jan 2015 15:32:48 +0000 (UTC)
Subject: master - cache: add pool deps for preload
Message-ID: <20150128153248.3583A60228@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3bb6d77dd6193755070c62c6f3adb93c1976f19
Commit:        c3bb6d77dd6193755070c62c6f3adb93c1976f19
Parent:        4f1309080a462988e10c11a328356a6c5c22dd6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 28 16:29:35 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 28 16:29:35 2015 +0100

cache: add pool deps for preload

for_each_sub_lv() normally does not put  pool_lv into deps.

So for now go around it in 'lv_preload()' and add explicit
call with pool.

TODO: think about a better way, we want pool_lv deps only in certain
moments, so maybe for_each_sub_lv() needs new arg for this.
---
 lib/activate/activate.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 151e714..00d3a10 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1879,6 +1879,11 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		if (!for_each_sub_lv((struct logical_volume *)ondisk_lv, &_preload_detached_lv, &detached))
 			goto_out;
 
+		/* ATM cache/thin pool is not scanned in  'for_each_sub_lv()', TODO explore better way */
+		if (lv_is_cache(ondisk_lv) &&
+		    !for_each_sub_lv(first_seg(ondisk_lv)->pool_lv, &_preload_detached_lv, &detached))
+			goto_out;
+
 		/*
 		 * Preload any snapshots that are being removed.
 		 */


