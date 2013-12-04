From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:31 +0000 (UTC)
Subject: master - cleanup: swap condition logic
Message-ID: <20131204133131.4E52360EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51783676fb8036832a08094fa34fd9458ee13711
Commit:        51783676fb8036832a08094fa34fd9458ee13711
Parent:        6d7a76ccbfcfe6579333a58c61a51d556ba8507f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 20:29:38 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:25 2013 +0100

cleanup: swap condition logic

Use easier to follow logic of code.
When checking for merging origin, do a merging.
---
 tools/lvconvert.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 273f56a..84479fe 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -780,12 +780,12 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 
 	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));
 
-	if (!lv_is_merging_origin(lv))
-		return poll_daemon(cmd, lv_full_name, uuid, background, 0,
-				   &_lvconvert_mirror_fns, "Converted");
-	else
+	if (lv_is_merging_origin(lv))
 		return poll_daemon(cmd, lv_full_name, uuid, background, 0,
 				   &_lvconvert_merge_fns, "Merged");
+
+	return poll_daemon(cmd, lv_full_name, uuid, background, 0,
+			   &_lvconvert_mirror_fns, "Converted");
 }
 
 static int _insert_lvconvert_layer(struct cmd_context *cmd,


