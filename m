From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:42:26 +0000 (UTC)
Subject: master - lvconvert: drop limit on thin pool conversion
Message-ID: <20130722104226.C1D9360DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1d5f6ae81f4723e6aeb2f04bd68cba59cd65403
Commit:        f1d5f6ae81f4723e6aeb2f04bd68cba59cd65403
Parent:        03efb7c2e121d68ba39691b796dae8c9606108d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 16 21:05:00 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 12:41:22 2013 +0200

lvconvert: drop limit on thin pool conversion

---
 tools/lvconvert.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 97ef7e4..ce28947 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1541,13 +1541,6 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/* TODO: decide what should be done here */
-	if (lv_is_thin_type(lv)) {
-		log_error("Converting segment type for %s/%s to mirror is not yet supported.",
-			 lv->vg->name, lv->name);
-		return 0;
-	}
-
 	/* Adjust mimage and/or log count */
 	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
 					     &old_mimage_count, &old_log_count,


