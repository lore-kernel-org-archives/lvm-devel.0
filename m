From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 18:03:39 -0500
Subject: master - lvconvert: update delaying message
Message-ID: <201711072303.vA7N3dun030249@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7fc7bc44a6e63f06363e27ca9f3b499d9a39eee
Commit:        f7fc7bc44a6e63f06363e27ca9f3b499d9a39eee
Parent:        e822a9f38ddf416378ccc5c09859a39ed9794306
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 7 23:19:17 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 8 00:02:54 2017 +0100

lvconvert: update delaying message

Make more obvious the operation just got delayed
(using same wording as with thin snapshots)
---
 tools/lvconvert.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8480072..eab7e6d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2057,15 +2057,15 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	 */
 	if (lv_is_active_locally(origin)) {
 		if (!lv_check_not_in_use(origin, 0)) {
-			log_print_unless_silent("Can't merge until origin volume is closed.");
+			log_print_unless_silent("Delaying merge since origin is open.");
 			merge_on_activate = 1;
 		} else if (!lv_check_not_in_use(lv, 0)) {
-			log_print_unless_silent("Can't merge until snapshot is closed.");
+			log_print_unless_silent("Delaying merge since snapshot is open.");
 			merge_on_activate = 1;
 		}
 	} else if (vg_is_clustered(origin->vg) && lv_is_active(origin)) {
 		/* When it's active somewhere else */
-		log_print_unless_silent("Can't check whether remotely active snapshot is open.");
+		log_print_unless_silent("Delaying merge since origin is remotely active.");
 		merge_on_activate = 1;
 	}
 


