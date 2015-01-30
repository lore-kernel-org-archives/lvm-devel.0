From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 30 Jan 2015 11:35:19 +0000 (UTC)
Subject: master - revert "cache: add pool deps for preload"
Message-ID: <20150130113519.6C1F760247@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=578b236a19fab565a4416b17cbc26d53a72b66db
Commit:        578b236a19fab565a4416b17cbc26d53a72b66db
Parent:        d021284bcfda0222f10787ea798077f312ee3275
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 30 12:31:09 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 30 12:33:52 2015 +0100

revert "cache: add pool deps for preload"

This reverts commit c3bb6d77dd6193755070c62c6f3adb93c1976f19.

Since we now have  for_each_sub_lv() scanning all sub LVs,
this commit could be safely reverted.
---
 lib/activate/activate.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index fc9bc4b..dbfb427 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1876,11 +1876,6 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		if (!for_each_sub_lv((struct logical_volume *)ondisk_lv, &_preload_detached_lv, &detached))
 			goto_out;
 
-		/* ATM cache/thin pool is not scanned in  'for_each_sub_lv()', TODO explore better way */
-		if (lv_is_cache(ondisk_lv) &&
-		    !for_each_sub_lv(first_seg(ondisk_lv)->pool_lv, &_preload_detached_lv, &detached))
-			goto_out;
-
 		/*
 		 * Preload any snapshots that are being removed.
 		 */


