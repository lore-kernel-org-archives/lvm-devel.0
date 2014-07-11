From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:55:40 +0000 (UTC)
Subject: master - cleanup: older gcc is not smart enough
Message-ID: <20140711115540.39AC260D03@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a62cea3371cfac10f74a135b1969120e10f48f60
Commit:        a62cea3371cfac10f74a135b1969120e10f48f60
Parent:        d7065f154e497ffe26006bf47b533b23383a8810
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 13:47:50 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:52:30 2014 +0200

cleanup: older gcc is not smart enough

Avoid gcc warning about uninitialized 'seg' variable.
It's not easy for older gcc compiler to deduce it's been set.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ff32f76..3a5f129 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2958,7 +2958,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		/* Swap normal LV with pool's metadata LV ? */
 		if (lv_is_pool(pool_lv)) {
 			/* Swap names between old and new metadata LV */
-			if (!detach_pool_metadata_lv(seg, &pool_metadata_lv))
+			if (!detach_pool_metadata_lv(first_seg(pool_lv), &pool_metadata_lv))
 				return_0;
 			old_name = metadata_lv->name;
 			if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))


