From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:26 +0000 (UTC)
Subject: master - cleanup: exit earlier in lv_rename_update
Message-ID: <20130718162626.F3CAC6073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bd67f9e5a3d53d78c83d7c554db300d6f82b97c
Commit:        8bd67f9e5a3d53d78c83d7c554db300d6f82b97c
Parent:        fd31cc9dfc2de1d2867c1c9f09e17403441ca6ad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 17 14:40:22 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:16:29 2013 +0200

cleanup: exit earlier in lv_rename_update

List doesn't need to be created when the metadata are not updated.
---
 lib/metadata/lv_manip.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cb6a6c2..e95deca 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3136,6 +3136,9 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	if (!update_mda)
+		return 1;
+
 	lvl.lv = lv;
 	dm_list_add(&lvs_changed, &lvl.list);
 
@@ -3143,9 +3146,6 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lv_is_cow(lv) && lv_is_virtual_origin(lvl2.lv = origin_from_cow(lv)))
 		dm_list_add_h(&lvs_changed, &lvl2.list);
 
-	if (!update_mda)
-		return 1;
-
 	log_verbose("Writing out updated volume group");
 	if (!vg_write(vg))
 		return 0;


