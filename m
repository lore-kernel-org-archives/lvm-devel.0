From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:02 +0000 (UTC)
Subject: master - lvm2app: Move percent_of_extents to lvm-percent.[h|c]
Message-ID: <20130702192602.9AFFB60D30@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=60c78e6aef9b744d6313ac0cf3ebb62b74066eb3
Commit:        60c78e6aef9b744d6313ac0cf3ebb62b74066eb3
Parent:        d52b6be455126e7b6a46c39127ca343982955b19
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jan 8 14:29:56 2013 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:33 2013 -0500

lvm2app: Move percent_of_extents to lvm-percent.[h|c]

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/misc/lvm-percent.c |    5 +++++
 lib/misc/lvm-percent.h |   17 +++++++++++++++++
 tools/toollib.c        |    6 ------
 tools/tools.h          |   16 ----------------
 4 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/lib/misc/lvm-percent.c b/lib/misc/lvm-percent.c
index 4b73db4..1dafa57 100644
--- a/lib/misc/lvm-percent.c
+++ b/lib/misc/lvm-percent.c
@@ -38,3 +38,8 @@ percent_t make_percent(uint64_t numerator, uint64_t denominator)
     }
 }
 
+uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup)
+{
+	return (uint32_t)(((uint64_t)percents * (uint64_t)count +
+			   ((roundup) ? 99 : 0)) / 100);
+}
diff --git a/lib/misc/lvm-percent.h b/lib/misc/lvm-percent.h
index bf30a7e..ff3de42 100644
--- a/lib/misc/lvm-percent.h
+++ b/lib/misc/lvm-percent.h
@@ -31,6 +31,21 @@
 typedef int32_t percent_t;
 
 typedef enum {
+	SIGN_NONE = 0,
+	SIGN_PLUS = 1,
+	SIGN_MINUS = 2
+} sign_t;
+
+typedef enum {
+	PERCENT_NONE = 0,
+	PERCENT_VG,
+	PERCENT_FREE,
+	PERCENT_LV,
+	PERCENT_PVS,
+	PERCENT_ORIGIN
+} percent_type_t;
+
+typedef enum {
 	PERCENT_0 = 0,
 	PERCENT_1 = 1000000,
 	PERCENT_100 = 100 * PERCENT_1,
@@ -41,4 +56,6 @@ typedef enum {
 float percent_to_float(percent_t v);
 percent_t make_percent(uint64_t numerator, uint64_t denominator);
 
+uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup);
+
 #endif
diff --git a/tools/toollib.c b/tools/toollib.c
index 46eb864..6e23e17 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1746,9 +1746,3 @@ int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	return 1;
 }
 
-/* Return percents of extents and avoid overflow, with optional roundup */
-uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup)
-{
-	return (uint32_t)(((uint64_t)percents * (uint64_t)count +
-			   ((roundup) ? 99 : 0)) / 100);
-}
diff --git a/tools/tools.h b/tools/tools.h
index 15d1f84..6e820bf 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -74,21 +74,6 @@ enum {
 #undef arg
 };
 
-typedef enum {
-	SIGN_NONE = 0,
-	SIGN_PLUS = 1,
-	SIGN_MINUS = 2
-} sign_t;
-
-typedef enum {
-	PERCENT_NONE = 0,
-	PERCENT_VG,
-	PERCENT_FREE,
-	PERCENT_LV,
-	PERCENT_PVS,
-	PERCENT_ORIGIN
-} percent_type_t;
-
 #define ARG_COUNTABLE 0x00000001	/* E.g. -vvvv */
 #define ARG_GROUPABLE 0x00000002	/* E.g. --addtag */
 
@@ -189,7 +174,6 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv, unsigned
 int mirror_remove_missing(struct cmd_context *cmd,
 			  struct logical_volume *lv, int force);
 
-uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup);
 
 int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		       activation_change_t activate);


