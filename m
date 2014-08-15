From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:31 +0000 (UTC)
Subject: master - lvconvert: show name of activated volume
Message-ID: <20140815130731.6EB7C60319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10e3715564e80e08daf04f0ae51067a04dfaa7b8
Commit:        10e3715564e80e08daf04f0ae51067a04dfaa7b8
Parent:        e8bbcda2a3a6799ff4e967276f9284c8b808584c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 14 11:12:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:44 2014 +0200

lvconvert: show name of activated volume

Display the name of volume that needs to be activated for merging.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e5d4d6d..a5daf80 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Print name of LV which on activation triggers delayed snapshot merge.
   Add lv_layout and lv_type LV reporting fields.
   Properly display lvs lv_attr volume type and target type bit for cache origin.
   Fix pvcreate_check() to update cache correctly after signature wiping.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 333459d..e369def 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2216,7 +2216,8 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 			return_0;
 		r = 1;
 		log_print_unless_silent("Merging of snapshot %s will start "
-					"next activation.", lv->name);
+					"next activation of %s.",
+					display_lvname(lv), display_lvname(origin));
 		goto out;
 	}
 
@@ -2323,7 +2324,8 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 		return_0;
 
 	log_print_unless_silent("Merging of thin snapshot %s will occur on "
-				"next activation.", lv->name);
+				"next activation of %s.",
+				display_lvname(lv), display_lvname(origin));
 	r = 1;
 out:
 	backup(lv->vg);


