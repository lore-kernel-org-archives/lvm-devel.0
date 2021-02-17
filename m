From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:17 +0000 (GMT)
Subject: stable-2.02 - lv_manip: avoid removing LV when converting
Message-ID: <20210217120117.5F6493896839@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5acbd709c18eab8ae455d0002892e756ed18fa13
Commit:        5acbd709c18eab8ae455d0002892e756ed18fa13
Parent:        1f6c287aaca04aa1a791c341cbff7b6cbff9a29b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 11:09:41 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:56:13 2021 +0100

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
index e9ce8cd28..8dd3e7140 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8334,7 +8334,9 @@ revert_new_lv:
 	lockd_free_lv(vg->cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
 
 	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
+	/* Do not remove anything for create during conversion operation */
+	if (!strncmp(cmd->name, "lvconvert", 9) ||
+	    !lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
 	else


