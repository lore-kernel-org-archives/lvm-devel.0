From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  8 Jan 2013 23:53:14 -0600
Subject: [PATCH 1/4] lvm2app: Move percent_of_extents to lvm-percent.[h|c]
In-Reply-To: <1357710797-18574-1-git-send-email-tasleson@redhat.com>
References: <1357710797-18574-1-git-send-email-tasleson@redhat.com>
Message-ID: <1357710797-18574-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/misc/lvm-percent.c |  5 +++++
 lib/misc/lvm-percent.h | 17 +++++++++++++++++
 tools/toollib.c        |  6 ------
 tools/tools.h          | 16 ----------------
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
index 669d772..9b7916a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1814,9 +1814,3 @@ int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	return 1;
 }
 
-/* Return percents of extents and avoid overflow, with optional roundup */
-uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup)
-{
-	return (uint32_t)(((uint64_t)percents * (uint64_t)count +
-			   ((roundup) ? 99 : 0)) / 100);
-}
diff --git a/tools/tools.h b/tools/tools.h
index a3ad9fd..e4f64bf 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -73,21 +73,6 @@ enum {
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
 
@@ -187,7 +172,6 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv, unsigned
 int mirror_remove_missing(struct cmd_context *cmd,
 			  struct logical_volume *lv, int force);
 
-uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup);
 
 int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		       activation_change_t activate);
-- 
1.7.11.7


