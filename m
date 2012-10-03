From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Oct 2012 13:14:50 +0000 (UTC)
Subject: master - cleanup: add proper cast for force_t
Message-ID: <20121003131450.C27FE313A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4648d33d0704de23876582f35786023ebc954fe9
Commit:        4648d33d0704de23876582f35786023ebc954fe9
Parent:        cf8e1a00937a7ef5eebf363898e237fd4a8dc392
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 19 15:13:21 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 3 15:06:17 2012 +0200

cleanup: add proper cast for force_t

---
 tools/lvremove.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvremove.c b/tools/lvremove.c
index 0252149..54094b1 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -26,7 +26,7 @@ static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
         if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
                 lv = origin;
 
-	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG), 0)) {
+	if (!lv_remove_with_dependencies(cmd, lv, (force_t) arg_count(cmd, force_ARG), 0)) {
 		stack;
 		return ECMD_FAILED;
 	}


