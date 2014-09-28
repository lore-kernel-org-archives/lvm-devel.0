From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 28 Sep 2014 11:56:44 +0000 (UTC)
Subject: master - toollib: introduce validate_lvname_param
Message-ID: <20140928115644.A30EB60041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d4baeba18646478e1edb7b26a9f9c74d6add1f5
Commit:        0d4baeba18646478e1edb7b26a9f9c74d6add1f5
Parent:        89e1190ef01943b59207c2093e643a6b06dc9be6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 28 12:57:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 28 13:49:01 2014 +0200

toollib: introduce validate_lvname_param

Function for parsing and validating of lvname parameter.
---
 tools/toollib.c |   37 +++++++++++++++++++++++++++++++++++++
 tools/toollib.h |    3 +++
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index eb7f058..ec9a95c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1949,3 +1949,40 @@ int get_and_validate_major_minor(const struct cmd_context *cmd,
 
 	return 1;
 }
+
+/*
+ * Validate lvname parameter
+ *
+ * If it contains vgname, it is extracted from lvname.
+ * If there is passed vgname, it is compared whether its the same name.
+ */
+int validate_lvname_param(struct cmd_context *cmd, const char **vg_name,
+			  const char **lv_name)
+{
+	const char *vgname;
+	const char *lvname;
+
+	if (!lv_name || !*lv_name)
+		return 1;  /* NULL lvname is ok */
+
+	/* If contains VG name, extract it. */
+	if (strchr(*lv_name, (int) '/')) {
+		if (!(vgname = _extract_vgname(cmd, *lv_name, &lvname)))
+			return_0;
+
+		if (!*vg_name)
+			*vg_name = vgname;
+		else if (strcmp(vgname, *vg_name)) {
+			log_error("Please use a single volume group name "
+				  "(\"%s\" or \"%s\")", vgname, *vg_name);
+			return 0;
+		}
+
+		*lv_name = lvname;
+	}
+
+	if (!apply_lvname_restrictions(*lv_name))
+		return_0;
+
+	return 1;
+}
diff --git a/tools/toollib.h b/tools/toollib.h
index b4fc24c..8aa82e0 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -144,4 +144,7 @@ int get_and_validate_major_minor(const struct cmd_context *cmd,
 				 const struct format_type *fmt,
 				 int32_t *major, int32_t *minor);
 
+int validate_lvname_param(struct cmd_context *cmd, const char **vg_name,
+			  const char **lv_name);
+
 #endif


