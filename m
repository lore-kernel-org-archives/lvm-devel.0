From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Dec 2013 11:41:13 +0000 (UTC)
Subject: master - lv_remove_single: update parameter name
Message-ID: <20131205114113.5609B60D5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f0300de9653063222c536b7cb04784d94787dd0
Commit:        6f0300de9653063222c536b7cb04784d94787dd0
Parent:        aa75698a1779c426914fde81bd57a016397017f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 5 12:39:02 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 5 12:40:47 2013 +0100

lv_remove_single: update parameter name

Since we have already a meaning for 'silent'
replace its name with more explanator suppress_remove_message
(updates recent commit).
---
 lib/metadata/lv_manip.c          |    4 ++--
 lib/metadata/metadata-exported.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9806758..62ca245 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4494,7 +4494,7 @@ void lv_set_hidden(struct logical_volume *lv)
 }
 
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
-		     force_t force, int silent)
+		     force_t force, int suppress_remove_message)
 {
 	struct volume_group *vg;
 	struct lvinfo info;
@@ -4651,7 +4651,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	backup(vg);
 
-	if (!silent && visible)
+	if (!suppress_remove_message && visible)
 		log_print_unless_silent("Logical volume \"%s\" successfully removed", lv->name);
 
 	return 1;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9798197..9d547bb 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -658,7 +658,7 @@ int lv_extend(struct logical_volume *lv,
 int lv_remove(struct logical_volume *lv);
 
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
-		     force_t force, int silent);
+		     force_t force, int suppress_remove_message);
 
 int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
 				force_t force, unsigned level);


