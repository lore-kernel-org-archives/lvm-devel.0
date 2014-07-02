From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:54 +0000 (UTC)
Subject: master - cleanup: a bit better error message
Message-ID: <20140702084854.9233460BAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57f8b33d5de8c93ee48f4d1caa69ac3fd45d05d0
Commit:        57f8b33d5de8c93ee48f4d1caa69ac3fd45d05d0
Parent:        165cfab7db386942162f819d247ce64ab5436119
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 2 09:50:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:43 2014 +0200

cleanup: a bit better error message

---
 tools/lvconvert.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 085fdcd..4f29416 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2759,13 +2759,12 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			return 0;
 		}
 		if (metadata_lv == pool_lv) {
-			log_error("Can't use same LV for thin pool data and metadata LV %s.",
-				  lp->pool_metadata_lv_name);
+			log_error("Can't use same LV for thin pool data and metadata LV %s/%s.",
+				  metadata_lv->vg->name, metadata_lv->name);
 			return 0;
 		}
 		if (lv_is_thin_type(metadata_lv)) {
-			log_error("Can't use thin pool logical volume %s/%s "
-				  "for thin pool metadata.",
+			log_error("Can't use thin type LV %s/%s for thin pool metadata.",
 				  metadata_lv->vg->name, metadata_lv->name);
 			return 0;
 		}


