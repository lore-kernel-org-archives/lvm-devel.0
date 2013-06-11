From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:08:55 +0000 (UTC)
Subject: master - cleanup: skip test if already tested for SIGN_PLUS
Message-ID: <20130611120855.9180A610D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1cdb6ca2b246bf5dc680abde3b0a2ea0192f1aaf
Commit:        1cdb6ca2b246bf5dc680abde3b0a2ea0192f1aaf
Parent:        1dcba13dfcccfb043f49708ca8f44c4d9fa9a260
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 13:09:11 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 13:55:26 2013 +0200

cleanup: skip test if already tested for SIGN_PLUS

---
 tools/lvresize.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 7b1bd50..558dff0 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -537,9 +537,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 					return ECMD_PROCESSED;
 			}
 		}
-	}
-
-	if (lp->sign == SIGN_MINUS) {
+	} else if (lp->sign == SIGN_MINUS) {
 		if (lp->extents >= lv->le_count) {
 			log_error("Unable to reduce %s below 1 extent",
 				  lp->lv_name);


