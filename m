From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 12:20:06 +0000 (UTC)
Subject: master - cleanup: lets make it really obvious for gcc
Message-ID: <20140711122006.A5AB360E53@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af219fbc042db96cc588c03557614b00097ccf6c
Commit:        af219fbc042db96cc588c03557614b00097ccf6c
Parent:        c0ebe78ef89e2a29d2dacc40184e41970ffc5564
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 14:19:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 14:19:22 2014 +0200

cleanup: lets make it really obvious for gcc

---
 tools/lvconvert.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c51158b..ba592a2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2958,7 +2958,8 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		/* Swap normal LV with pool's metadata LV ? */
 		if (lv_is_pool(pool_lv)) {
 			/* Swap names between old and new metadata LV */
-			if (!detach_pool_metadata_lv(first_seg(pool_lv), &pool_metadata_lv))
+			seg = first_seg(pool_lv);
+			if (!detach_pool_metadata_lv(seg, &pool_metadata_lv))
 				return_0;
 			old_name = metadata_lv->name;
 			if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))


