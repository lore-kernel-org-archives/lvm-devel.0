From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Apr 2015 16:27:11 +0000 (UTC)
Subject: master - config: add CFG_DEFAULT_COMMENTED to comment out default value on output
Message-ID: <20150430162711.0FF316006F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11e0dc40dcae9021bb52d60403fd1a3b8b40c58c
Commit:        11e0dc40dcae9021bb52d60403fd1a3b8b40c58c
Parent:        8f25606d3acd9f5e314b40384ef2366ef63bf4b1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 30 18:26:56 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 30 18:26:56 2015 +0200

config: add CFG_DEFAULT_COMMENTED to comment out default value on output

---
 lib/config/config.c          |    2 +-
 lib/config/config.h          |    6 ++++--
 lib/config/config_settings.h |    1 +
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 084f3f2..32b3c66 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1664,7 +1664,7 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	/* Usual tree view with nodes and their values. */
 	if ((out->tree_spec->type != CFG_DEF_TREE_CURRENT) &&
 	    (out->tree_spec->type != CFG_DEF_TREE_DIFF) &&
-	    (cfg_def->flags & CFG_DEFAULT_UNDEFINED)) {
+	    (cfg_def->flags & (CFG_DEFAULT_UNDEFINED | CFG_DEFAULT_COMMENTED))) {
 		space_prefix = ((len = strspn(line, "\t "))) ? dm_pool_strndup(out->mem, line, len) : NULL;
 		fprintf(out->fp, "%s%s%s\n", space_prefix ? : "", "# ", line + len);
 		if (space_prefix)
diff --git a/lib/config/config.h b/lib/config/config.h
index ce31e50..0b7221c 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -113,10 +113,12 @@ typedef union {
 #define CFG_PROFILABLE_METADATA 0x030
 /* whether the default value is undefned */
 #define CFG_DEFAULT_UNDEFINED	0x040
+/* whether the default value is commented out on output */
+#define CFG_DEFAULT_COMMENTED	0x080
 /* whether the default value is calculated during run time */
-#define CFG_DEFAULT_RUN_TIME	0x080
+#define CFG_DEFAULT_RUN_TIME	0x100
 /* whether the configuration setting is disabled (and hence defaults always used) */
-#define CFG_DISABLED		0x100
+#define CFG_DISABLED		0x200
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 9fd9be6..31609d4 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -48,6 +48,7 @@
  *                                 CFG_PROFILABLE - this node is customizable by a profile
  *                                 CFG_PROFILABLE_METADATA - profilable and attachable to VG/LV metadata
  *                                 CFG_DEFAULT_UNDEFINED - node's default value is undefined
+ *                                 CFG_DEFAULT_COMMENTED - node's default value is commented out on output
  *                                 CFG_DISABLED - configuration is disabled (defaults always used)
  *
  * type:		       Allowed type for the value of simple configuation setting, one of:


