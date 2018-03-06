From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:45:50 -0500
Subject: master - lvremove: drop duplicate check for active LV
Message-ID: <201803061445.w26EjoJr026654@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f04abd1f8a7eea9edf473be17ae1e2aea1a00ee6
Commit:        f04abd1f8a7eea9edf473be17ae1e2aea1a00ee6
Parent:        23de09aeb87ec10bd1a553ea8868e2f946117232
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 6 13:31:06 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:40:31 2018 +0100

lvremove: drop duplicate check for active LV

Since this code branch already tested LV is active,
avoid repeating same query.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3ed3e5a..b282caa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Skip duplicate check for active LV when prompting for its removal.
   Activate correct lock holding LV when it is cached.
   Do not modify archived metadata when removing striped raid.
   Fix memleak on error path when obtaining lv_raid_data_offset.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 88b0d9d..d4a6107 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6040,8 +6040,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 		if ((force == PROMPT) &&
 		    !lv_is_pending_delete(lv) &&
-		    lv_is_visible(lv) &&
-		    lv_is_active(lv)) {
+		    lv_is_visible(lv)) {
 			if (yes_no_prompt("Do you really want to remove%s active "
 					  "%slogical volume %s? [y/n]: ",
 					  ask_discard ? " and DISCARD" : "",


