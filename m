From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:37 +0000 (GMT)
Subject: main - lv_manip: avoid removing LV when converting
Message-ID: <20210217105437.E1AA33857C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=096edeee718a4c5524e91fa613f015c9061d6a84
Commit:        096edeee718a4c5524e91fa613f015c9061d6a84
Parent:        3ef0861355ad70589959d1e92b53f91424197946
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 11:09:41 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:21:35 2021 +0100

lv_manip: avoid removing LV when converting

In some cases we use 'creation' also during conversion.
Here it can be actually unwanted side effect we may remove
not just newly created layers - but also original converted LV.

So until we make clear how to properly revert from some errors
in middle of conversion, disable removal for any 'lvconvert' commands.
---
 lib/metadata/lv_manip.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 32bdc7990..5784e407d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8809,7 +8809,9 @@ revert_new_lv:
 	lockd_free_lv(vg->cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
 
 	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
+	/* Do not remove anything for create during conversion operation */
+	if (!strncmp(cmd->name, "lvconvert", 9) ||
+	    !lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
 	else


