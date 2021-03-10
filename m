From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:29 +0000 (GMT)
Subject: main - toollib: prioritize processing thin-pool first
Message-ID: <20210310231929.6290B3858001@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dac827470195f46393522b20ef5678136f72126b
Commit:        dac827470195f46393522b20ef5678136f72126b
Parent:        7a99dac9ad44f0097fb64c48f7fe14a10aea07b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 22:02:38 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:18:01 2021 +0100

toollib: prioritize processing thin-pool first

When generating list of processed LV, add thin-pool to the head of the
list, while other LVs are added on tail.

This makes it easier when removing many thin volumes, to recognize easily
when its thin-pool is also supposed to be removed.
---
 tools/toollib.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 3c81de26b..de51632a6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3082,7 +3082,11 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			goto out;
 		}
 		final_lvl->lv = lvl->lv;
-		dm_list_add(&final_lvs, &final_lvl->list);
+		if (lv_is_thin_pool(lvl->lv)) {
+			/* Add to the front of the list */
+			dm_list_add_h(&final_lvs, &final_lvl->list);
+		} else
+			dm_list_add(&final_lvs, &final_lvl->list);
 	}
 	log_set_report_object_name_and_id(NULL, NULL);
 


