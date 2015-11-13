From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:23 +0000 (UTC)
Subject: master - coverity: model some function
Message-ID: <20151113101923.8A2D660FDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3089f5ab15dbab151f18067acbcdf582a90d932d
Commit:        3089f5ab15dbab151f18067acbcdf582a90d932d
Parent:        8d258c7df487d59a524643b71adba602696c5287
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 11 22:03:42 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:18:27 2015 +0100

coverity: model some function

Reduce number of false-positives and model functions in a way
Coverity is able to understand it.
---
 coverity/coverity_model.c |   94 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 94 insertions(+), 0 deletions(-)

diff --git a/coverity/coverity_model.c b/coverity/coverity_model.c
index 8f54e1f..947e9c8 100644
--- a/coverity/coverity_model.c
+++ b/coverity/coverity_model.c
@@ -12,3 +12,97 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+/*
+ * Coverity usage:
+ *
+ * translate model into xml
+ * cov-make-library -of coverity_model.xml coverity_model.c
+ *
+ * compile (using outdir 'cov'):
+ * cov-build --dir=cov make CC=gcc
+ *
+ * analyze (agressively, using 'cov')
+ * cov-analyze --dir cov --wait-for-license --hfa --concurrency --enable-fnptr --enable-constraint-fpp --security --all --aggressiveness-level=high --field-offset-escape --user-model-file=coverity/coverity_model.xml
+ *
+ * generate html output (to 'html' from 'cov'):
+ * cov-format-errors --dir cov  --html-output html
+ */
+
+struct lv_segment;
+
+struct logical_volume {
+	struct lv_segment *seg;
+};
+
+struct lv_segment *first_seg(const struct logical_volume *lv)
+{
+	return lv->seg;
+}
+
+struct lv_segment *last_seg(const struct logical_volume *lv)
+{
+	return lv->seg;
+}
+
+/* simple_memccpy() from glibc */
+void *memccpy(void *dest, const void *src, int c, size_t n)
+{
+	const char *s = src;
+	char *d = dest;
+
+	while (n-- > 0)
+		if ((*d++ = *s++) == (char) c)
+			return d;
+
+	return 0;
+}
+
+/*
+ * Added extra pointer check to not need these models,
+ * for now just keep then in file
+ */
+
+/*
+struct cmd_context;
+struct profile;
+
+const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile *profile)
+{
+        return "text";
+}
+
+const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, struct profile *profile)
+{
+        return "text";
+}
+*/
+
+/*
+ * Until fixed coverity case# 00531860:
+ *   A FORWARD_NULL false positive on a recursive function call
+ *
+ * model also these functions:
+ */
+/*
+const struct dm_config_node;
+const struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int id, struct profile *profile)
+{
+	const struct dm_config_node *cn;
+
+	return cn;
+}
+
+const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile)
+{
+	const struct dm_config_node *cn;
+
+	return cn;
+}
+
+int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profile)
+{
+	int b;
+
+	return b;
+}
+*/


