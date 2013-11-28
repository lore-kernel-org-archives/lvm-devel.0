From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:49:07 +0000 (UTC)
Subject: master - cleanup: tab indent
Message-ID: <20131128114907.B1044606DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce8ebda3fc0e8275d15f8cdc7f6f21162c7c1636
Commit:        ce8ebda3fc0e8275d15f8cdc7f6f21162c7c1636
Parent:        6bf6430ae94e2a0e8239b198e35b53abbaa3f041
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 28 11:35:53 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:48:01 2013 +0100

cleanup: tab indent

---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1fec9a5..fe9e656 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4725,7 +4725,7 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 		    yes_no_prompt("Removing origin %s will also remove %u "
 				  "snapshots(s). Proceed? [y/n]: ",
 				  lv->name, lv->origin_count) == 'n')
-                        goto no_remove;
+			goto no_remove;
 
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!lv_remove_with_dependencies(cmd, dm_list_struct_base(snh, struct lv_segment,
@@ -4762,7 +4762,7 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	    (yes_no_prompt("Removal of pool metadata spare logical volume \"%s\" "
 			   "disables automatic recovery attempts after damage "
 			   "to a thin pool. Proceed? [y/n]: ", lv->name) == 'n'))
-                goto no_remove;
+		goto no_remove;
 
 	return lv_remove_single(cmd, lv, force);
 


