From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  3 Dec 2015 14:40:52 +0000 (UTC)
Subject: master - lvconvert: Reinstate mirror to raid conversions.
Message-ID: <20151203144052.685DD60D70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aec58c862064e2b9dd5b0ebb54473340ebd97f7f
Commit:        aec58c862064e2b9dd5b0ebb54473340ebd97f7f
Parent:        3bbf89e9ec92388cbfa722c0fbb6ff3fad0232aa
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Dec 3 14:40:14 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Dec 3 14:40:14 2015 +0000

lvconvert: Reinstate mirror to raid conversions.

Reinstate conversions from mirror to raid stopped
by commit 46c8d6bb8ae91ee67c8633496cc6c3d92bb4f3ce
(lvconvert: Improve message for raid without -m).
---
 tools/lvconvert.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b309b9e..82b804f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -242,9 +242,9 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 	if (!type_str || !*type_str)
 		return 1;
 
-	if (!strcmp(type_str, "mirror") || !strncmp(type_str, "raid", 4)) {
+	if (!strcmp(type_str, "mirror")) {
 		if (!arg_count(cmd, mirrors_ARG)) {
-			log_error("Mirror and raid conversions require -m/--mirrors");
+			log_error("Conversions to --type mirror require -m/--mirrors");
 			return 0;
 		}
 		return 1;
@@ -1734,6 +1734,11 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return 0;
 	}
 
+	if (seg_is_linear(seg) && !arg_count(cmd, mirrors_ARG)) {
+		log_error("Raid conversions require -m/--mirrors");
+		return 0;
+	}
+
 	/* Change number of RAID1 images */
 	if (arg_count(cmd, mirrors_ARG) || arg_count(cmd, splitmirrors_ARG)) {
 		image_count = lv_raid_image_count(lv);


