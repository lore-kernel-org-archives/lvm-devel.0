From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:50 +0000 (UTC)
Subject: dev-prajnoha-selout - selout: add struct for report selection
Message-ID: <20140509065650.1790D60F95@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ab77a026b93fb1e10a1c10a5ae3d4ff527cf0d9
Commit:        6ab77a026b93fb1e10a1c10a5ae3d4ff527cf0d9
Parent:        929a4515fe7aff7daa3a7521b0c98789c0c99a8f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 28 11:56:29 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri May 9 08:51:00 2014 +0200

selout: add struct for report selection

---
 libdm/libdm-report.c |   75 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index d71a8c7..9cd9028 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -68,6 +68,81 @@ struct field_properties {
 };
 
 /*
+ * Report selection
+ */
+struct op_def {
+	const char *string;
+	uint32_t flags;
+	const char *desc;
+};
+
+#define FLD_CMP_MASK	0x000FF000
+#define FLD_CMP_EQUAL	0x00001000
+#define FLD_CMP_NOT	0x00002000
+#define FLD_CMP_GT	0x00004000
+#define FLD_CMP_LT	0x00008000
+#define FLD_CMP_REGEX	0x00010000
+
+static struct op_def _op_cmp[] = {
+	{ "=", FLD_CMP_EQUAL, "Equal to" },
+	{ "!=", FLD_CMP_NOT|FLD_CMP_EQUAL, "Not equal" },
+	{ ">=", FLD_CMP_GT|FLD_CMP_EQUAL, "Greater than or equal to" },
+	{ ">", FLD_CMP_GT, "Greater than" },
+	{ "<=", FLD_CMP_LT|FLD_CMP_EQUAL, "Lesser than or equal to" },
+	{ "<", FLD_CMP_LT, "Lesser than" },
+	{ "=~", FLD_CMP_REGEX, "Matching regular expression" },
+	{ "!~", FLD_CMP_REGEX|FLD_CMP_NOT, "Not matching regular expression" },
+	{ NULL, 0, NULL }
+};
+
+#define SEL_MASK		0x00FF
+#define SEL_ITEM		0x0001
+#define SEL_AND 		0x0002
+#define SEL_OR			0x0004
+
+#define SEL_MODIFIER_MASK	0x0F00
+#define SEL_MODIFIER_NOT	0x0100
+
+#define SEL_PRECEDENCE_MASK	0xF000
+#define SEL_PRECEDENCE_PS	0x1000
+#define SEL_PRECEDENCE_PE	0x2000
+
+#define SEL_AND_TOK		"+"
+#define SEL_OR_TOK		","
+#define SEL_NOT_TOK		"!"
+#define SEL_PS_TOK		"("
+#define SEL_PE_TOK		")"
+
+static struct op_def _op_log[] = {
+        { SEL_AND_TOK, SEL_AND, "Logical conjunction" },
+        { SEL_OR_TOK, SEL_OR, "Logical disjunction" },
+        { SEL_NOT_TOK, SEL_MODIFIER_NOT, "Logical negation" },
+        { SEL_PS_TOK, SEL_PRECEDENCE_PS, "Left parenthesis" },
+        { SEL_PE_TOK, SEL_PRECEDENCE_PE, "Right parenthesis" },
+        { NULL,  0, NULL},
+};
+
+struct field_selection {
+	struct field_properties *fp;
+	uint32_t flags;
+	union {
+		const char *s;
+		uint64_t i;
+		double d;
+		struct dm_regex *r;
+	} v;
+};
+
+struct selection_node {
+	struct dm_list list;
+	uint32_t type;
+	union {
+		struct field_selection *item;
+		struct dm_list set;
+	} selection;
+};
+
+/*
  * Report data field
  */
 struct dm_report_field {


