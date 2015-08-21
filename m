From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Aug 2015 13:36:19 +0000 (UTC)
Subject: master - cleanup: add .
Message-ID: <20150821133619.EF22860DC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d9e7d48fb34010f0e1447e99a92193b153acdc3
Commit:        6d9e7d48fb34010f0e1447e99a92193b153acdc3
Parent:        c868609cff48597db50ac5bb98ecba0ecc828dbd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 20 15:09:23 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 21 15:35:45 2015 +0200

cleanup: add .

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5630234..88c516b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5327,7 +5327,7 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	log_print_unless_silent("Logical volume %s successfully resized", lp->lv_name);
+	log_print_unless_silent("Logical volume %s successfully resized.", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
 	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL))


