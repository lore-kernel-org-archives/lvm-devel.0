From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 26 Jun 2018 06:19:27 -0400
Subject: 2018-06-01-stable - segtype: add linear
Message-ID: <201806261019.w5QAJRLd011056@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=763c65314ef9f5c7bfa2327054177f3f831ae6a5
Commit:        763c65314ef9f5c7bfa2327054177f3f831ae6a5
Parent:        24aee732a58a8d45acf90cbdf1d0cf30fe603a09
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed May 30 12:44:24 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jun 26 12:15:44 2018 +0200

segtype: add linear

Add linear segtype addressing FIXME in preparation
for linear <-> striped convenience conversion support

(cherry picked from commit de66704253653305e4513637735a078af00912b7)
---
 lib/commands/toolcontext.c |    1 +
 lib/metadata/segtype.c     |    4 ----
 lib/metadata/segtype.h     |    4 +++-
 lib/striped/striped.c      |   19 ++++++++++++++-----
 4 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e9f9357..c9596e2 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1462,6 +1462,7 @@ static int _init_segtypes(struct cmd_context *cmd)
 	struct segment_type *segtype;
 	struct segtype_library seglib = { .cmd = cmd, .lib = NULL };
 	struct segment_type *(*init_segtype_array[])(struct cmd_context *cmd) = {
+		init_linear_segtype,
 		init_striped_segtype,
 		init_zero_segtype,
 		init_error_segtype,
diff --git a/lib/metadata/segtype.c b/lib/metadata/segtype.c
index d0508ca..f88dbfa 100644
--- a/lib/metadata/segtype.c
+++ b/lib/metadata/segtype.c
@@ -22,10 +22,6 @@ struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 {
 	struct segment_type *segtype;
 
-	/* FIXME Register this properly within striped.c */
-	if (!strcmp(str, SEG_TYPE_NAME_LINEAR))
-		str = SEG_TYPE_NAME_STRIPED;
-
 	dm_list_iterate_items(segtype, &cmd->segtypes)
 		if (!strcmp(segtype->name, str))
 			return segtype;
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 40b41ec..9c05836 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -68,6 +68,7 @@ struct dev_manager;
 #define SEG_RAID6		SEG_RAID6_ZR
 
 #define SEG_STRIPED_TARGET	(1ULL << 39)
+#define SEG_LINEAR_TARGET	(1ULL << 40)
 
 #define SEG_UNKNOWN		(1ULL << 63)
 
@@ -105,7 +106,7 @@ struct dev_manager;
 #define SEG_TYPE_NAME_RAID6_RS_6	"raid6_rs_6"
 #define SEG_TYPE_NAME_RAID6_N_6		"raid6_n_6"
 
-#define segtype_is_linear(segtype)	(!strcmp(segtype->name, SEG_TYPE_NAME_LINEAR))
+#define segtype_is_linear(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_LINEAR))
 #define segtype_is_striped_target(segtype)	((segtype)->flags & SEG_STRIPED_TARGET ? 1 : 0)
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
 #define segtype_is_cache_pool(segtype)	((segtype)->flags & SEG_CACHE_POOL ? 1 : 0)
@@ -274,6 +275,7 @@ struct segtype_library;
 int lvm_register_segtype(struct segtype_library *seglib,
 			 struct segment_type *segtype);
 
+struct segment_type *init_linear_segtype(struct cmd_context *cmd);
 struct segment_type *init_striped_segtype(struct cmd_context *cmd);
 struct segment_type *init_zero_segtype(struct cmd_context *cmd);
 struct segment_type *init_error_segtype(struct cmd_context *cmd);
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index bca4c2c..498b202 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -230,7 +230,7 @@ static struct segtype_handler _striped_ops = {
 	.destroy = _striped_destroy,
 };
 
-struct segment_type *init_striped_segtype(struct cmd_context *cmd)
+static struct segment_type *_init_segtype(struct cmd_context *cmd, const char *name, uint64_t target)
 {
 	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
@@ -238,11 +238,20 @@ struct segment_type *init_striped_segtype(struct cmd_context *cmd)
 		return_NULL;
 
 	segtype->ops = &_striped_ops;
-	segtype->name = SEG_TYPE_NAME_STRIPED;
-	segtype->flags = SEG_STRIPED_TARGET |
-	    SEG_CAN_SPLIT | SEG_AREAS_STRIPED;
+	segtype->name = name;
+	segtype->flags = target | SEG_CAN_SPLIT | SEG_AREAS_STRIPED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
-
 	return segtype;
 }
+
+struct segment_type *init_striped_segtype(struct cmd_context *cmd)
+{
+	return _init_segtype(cmd, SEG_TYPE_NAME_STRIPED, SEG_STRIPED_TARGET);
+}
+
+
+struct segment_type *init_linear_segtype(struct cmd_context *cmd)
+{
+	return _init_segtype(cmd, SEG_TYPE_NAME_LINEAR, SEG_LINEAR_TARGET);
+}


