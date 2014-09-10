From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Sep 2014 20:05:35 +0000 (UTC)
Subject: master - cleanup: add stacktrace for error path
Message-ID: <20140910200535.7B74660DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17e8b6aa686958c49b9a4752ea235bbdc99a7643
Commit:        17e8b6aa686958c49b9a4752ea235bbdc99a7643
Parent:        4f1af9b99a0fb0824d8ab6b3b4c9ed3c61e89ee4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 8 22:36:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 10 20:06:20 2014 +0200

cleanup: add stacktrace for error path

---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fcf9975..60aa6f8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3963,13 +3963,13 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (update_mda && !archive(vg))
-		return 0;
+		return_0;
 
 	/* rename sub LVs */
 	lv_names.old = lv->name;
 	lv_names.new = new_name;
 	if (!for_each_sub_lv(lv, _rename_cb, (void *) &lv_names))
-		return 0;
+		return_0;
 
 	/* rename main LV */
 	if (!(lv->name = dm_pool_strdup(cmd->mem, new_name))) {


