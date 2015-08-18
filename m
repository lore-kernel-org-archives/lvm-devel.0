From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:01:39 +0000 (UTC)
Subject: master - cleanup: add cast
Message-ID: <20150818130139.2228661037@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d08a49790c180e10e8a6d35cbd43d7eb214bf30
Commit:        3d08a49790c180e10e8a6d35cbd43d7eb214bf30
Parent:        55a9262bdbc53acbd79035e904e7e00df8eec88b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 12:39:17 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 15:00:08 2015 +0200

cleanup: add cast

---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 36c4593..0897e09 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2002,7 +2002,7 @@ static int _lvconvert_uncache(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!lv_remove_single(cmd, first_seg(lv)->pool_lv, lp->force, 0))
+	if (!lv_remove_single(cmd, first_seg(lv)->pool_lv, (force_t) lp->force, 0))
 		return_0;
 
 	log_print_unless_silent("Logical volume %s is not cached.", display_lvname(lv));


