From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:37 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select: add structs for report selection
Message-ID: <20140606120337.8D8A860180@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e9c2000026b9babbca378bdaf6407ea76f20fb8
Commit:        5e9c2000026b9babbca378bdaf6407ea76f20fb8
Parent:        026b9eefe76fe581b6e256b8aebea8742b0da103
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:37:41 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 11:11:20 2014 +0200

report: select: add structs for report selection

This is rebased and edited version of the original design and
patch proposed by Jun'ichi Nomura:
  http://www.redhat.com/archives/dm-devel/2007-April/msg00025.html

This patch defines operators and structures that will be used
to store the report selection against which the actual values
reported will be checked.

  Selection operands
  ------------------
    fields              - reporting fields
    numbers	        - integer or floating point, non-negative
    strings	        - characters quoted by ' or " or unquoted
    regular expression  - characters quoted by ' or " or unquoted

  Selection operators
  -------------------
    Comparison operators:
        =~  - Matching regular expression
        !~  - Not matching regular expression
         =  - Equal to
        !=  - Not equal
        >=  - Greater than or equal to
         >  - Greater than
        <=  - Lesser than or equal to
         <  - Lesser than

    Logical and grouping operators:
        &&  - Logical conjunction
         ,  - Logical conjunction (alternative)
        ||  - Logical disjunction
         /  - Logical disjunction (alternative)
         !  - Logical negation
         (  - Left parenthesis
         )  - Right parenthesis
---
 libdm/libdm-report.c |   77 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 77 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 384648e..9bab350 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -68,6 +68,83 @@ struct field_properties {
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
+#define FLD_CMP_NUMBER  0x00020000
+
+/*
+ * When defining operators, always define longer one before
+ * shorter one if one is a prefix of another!
+ * (e.g. =~ comes before =)
+*/
+static struct op_def _op_cmp[] = {
+	{ "=~", FLD_CMP_REGEX, "Matching regular expression" },
+	{ "!~", FLD_CMP_REGEX|FLD_CMP_NOT, "Not matching regular expression" },
+	{ "=", FLD_CMP_EQUAL, "Equal to" },
+	{ "!=", FLD_CMP_NOT|FLD_CMP_EQUAL, "Not equal" },
+	{ ">=", FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL, "Greater than or equal to" },
+	{ ">", FLD_CMP_NUMBER|FLD_CMP_GT, "Greater than" },
+	{ "<=", FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL, "Lesser than or equal to" },
+	{ "<", FLD_CMP_NUMBER|FLD_CMP_LT, "Lesser than" },
+	{ NULL, 0, NULL }
+};
+
+#define SEL_MASK		0x000000FF
+#define SEL_ITEM		0x00000001
+#define SEL_AND 		0x00000002
+#define SEL_OR			0x00000004
+
+#define SEL_MODIFIER_MASK	0x00000F00
+#define SEL_MODIFIER_NOT	0x00000100
+
+#define SEL_PRECEDENCE_MASK	0x0000F000
+#define SEL_PRECEDENCE_PS	0x00001000
+#define SEL_PRECEDENCE_PE	0x00002000
+
+static struct op_def _op_log[] = {
+        { "&&", SEL_AND, "Logical conjunction" },
+	{ ",", SEL_AND, "Logical conjunction (alternative)" },
+        { "||", SEL_OR, "Logical disjunction" },
+	{ "/", SEL_OR, "Logical disjunction (alternative)" },
+        { "!", SEL_MODIFIER_NOT, "Logical negation" },
+        { "(", SEL_PRECEDENCE_PS, "Left parenthesis" },
+        { ")", SEL_PRECEDENCE_PE, "Right parenthesis" },
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


