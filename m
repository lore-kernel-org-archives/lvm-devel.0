From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue, 12 Jul 2016 15:23:10 +0000 (UTC)
Subject: master - lvchange: resync attempts on raid0 cause segfaults
Message-ID: <20160712152310.18DA060B3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c77c59f3d9a97b43cd2bd9be1c5892aea384f857
Commit:        c77c59f3d9a97b43cd2bd9be1c5892aea384f857
Parent:        dcbcc65dc2177c55c4a7286e6e95d9a740c731c7
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jul 12 17:20:38 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jul 12 17:23:05 2016 +0200

lvchange: resync attempts on raid0 cause segfaults

Resync attempts on raid0/raid0_meta via 'lvchange --resync ...'
cause segfaults.

'lvchange --syncaction ...' doesn't get rejected either.

Prohibit both on raid0/raid0_meta LVs.

- resolves rhbz1354656
---
 tools/lvchange.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index c5461f9..4b02ba9 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -326,8 +326,9 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 	dm_list_init(&device_list);
 
-	if (!seg_is_mirror(seg) && !seg_is_raid(seg)) {
-		log_error("Unable to resync %s.  It is not RAID or mirrored.",
+	if (seg_is_any_raid0(seg) ||
+	    (!seg_is_mirror(seg) && !seg_is_raid(seg))) {
+		log_error("Unable to resync %s.  It is not RAID4/5/6/10 or mirrored.",
 			  display_lvname(lv));
 		return 0;
 	}
@@ -1179,9 +1180,17 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    !_lvchange_resync(cmd, lv))
 		return_ECMD_FAILED;
 
-	if (arg_is_set(cmd, syncaction_ARG) &&
-	    !lv_raid_message(lv, arg_str_value(cmd, syncaction_ARG, NULL)))
-		return_ECMD_FAILED;
+	if (arg_is_set(cmd, syncaction_ARG)) {
+		struct lv_segment *seg = first_seg(lv);
+
+		if (seg_is_any_raid0(seg)) {
+			log_error("Unable to sync raid0 LV %s.", display_lvname(lv));
+			return_ECMD_FAILED;
+		}
+		
+		if (!lv_raid_message(lv, arg_str_value(cmd, syncaction_ARG, NULL)))
+			return_ECMD_FAILED;
+	}
 
 	/* activation change */
 	if (arg_is_set(cmd, activate_ARG)) {


