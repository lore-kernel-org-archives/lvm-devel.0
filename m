From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:51 +0000 (UTC)
Subject: master - lvconvert: do not activate cache pool
Message-ID: <20140408090251.65A4B60F50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43f849296e1e4b5450681e275495450bf041a11b
Commit:        43f849296e1e4b5450681e275495450bf041a11b
Parent:        db4cf3010640307d1764cebf2c7497676d209383
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 7 23:52:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:14 2014 +0200

lvconvert: do not activate cache pool

Cache pool cannot be active alone.
---
 tools/lvconvert.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1331620..94d870a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2698,8 +2698,11 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/* Allow to have only thinpool active and restore it's active state */
-	activate_pool = lv_is_active(pool_lv);
+	if (segtype_is_cache_pool(lp->segtype))
+		activate_pool = 0; /* Cannot activate cache pool */
+	else
+		/* Allow to have only thinpool active and restore it's active state */
+		activate_pool = lv_is_active(pool_lv);
 
 	/* We are changing target type, so deactivate first */
 	if (!deactivate_lv(cmd, pool_lv)) {


