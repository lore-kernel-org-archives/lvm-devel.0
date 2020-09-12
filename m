From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 Sep 2020 11:24:44 +0000 (GMT)
Subject: master - revert "lvconvert: check if LV has snapshot type"
Message-ID: <20200912112444.6414338708A2@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=463a61e62e32aa81391f40468d48d19948cd5062
Commit:        463a61e62e32aa81391f40468d48d19948cd5062
Parent:        93e252c4a30eddd642a0b2e2e9c00161f4895a0a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 12:07:12 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 12 12:55:17 2020 +0200

revert "lvconvert: check if LV has snapshot type"

This reverts commit 7db124774a2b79105e7c9c6b42df88219fc070ca.
Actually we need to check for lv_is_cow().
---
 tools/lvconvert.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6ab8f6d2c..d420eb52f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1825,11 +1825,6 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	struct volume_group *vg = cow->vg;
 	const char *cow_name = display_lvname(cow);
 
-	if (!lv_is_snapshot(cow)) {
-		log_error(INTERNAL_ERROR "Cow volume %s is not a snapshot.", cow_name);
-		return 0;
-	}
-
 	if (lv_is_virtual_origin(origin_from_cow(cow))) {
 		log_error("Unable to split off snapshot %s with virtual origin.", cow_name);
 		return 0;


