From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:50 +0000 (UTC)
Subject: master - cleanup: drop extra braces
Message-ID: <20140815130750.BC04960CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff33d215ba488bc3abf7bb33f1c25ee1fc0e65c4
Commit:        ff33d215ba488bc3abf7bb33f1c25ee1fc0e65c4
Parent:        f183995f8ead0bf63aea6ce7983871015dc3efff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 15 13:52:21 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:45 2014 +0200

cleanup: drop extra braces

---
 tools/lvchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index f3bef8b..91c8087 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -993,7 +993,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    !arg_count(cmd, setactivationskip_ARG))
 	    /* Rest can be changed for stacked thin pool meta/data volumes */
 	    ;
-	else if (!(lv_is_visible(lv)) && !lv_is_virtual_origin(lv)) {
+	else if (!lv_is_visible(lv) && !lv_is_virtual_origin(lv)) {
 		log_error("Unable to change internal LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;


