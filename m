From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Oct 2016 15:51:13 +0000 (UTC)
Subject: master - cleanup: drop test for NULL
Message-ID: <20161003155113.EBB9460A70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77ffd39dfb4145e444fb9ab2394d807207db8083
Commit:        77ffd39dfb4145e444fb9ab2394d807207db8083
Parent:        9fe4f2337bfaaa30e647ed1d20be7fb76d598559
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 3 14:37:08 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 3 17:49:56 2016 +0200

cleanup: drop test for NULL

Since lp->segtype has been already checked for not-being NULL,
drop this test so Coverity is not later confused it 'can be a NULL'.
---
 tools/lvconvert.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3607247..2f38c9d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4460,7 +4460,8 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (activation() && lp->segtype && lp->segtype->ops->target_present &&
+	/* lv->segtype can't be NULL */
+	if (activation() && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel.", lp->segtype->name);


