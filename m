From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 23 Jun 2014 08:11:45 +0000 (UTC)
Subject: master - select: add FLD_UNCOMPARABLE flag for fields which can't be compared
Message-ID: <20140623081145.0A53360D89@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d48ef7f04e0b3b14d7a9bf622979e42141f34f2
Commit:        2d48ef7f04e0b3b14d7a9bf622979e42141f34f2
Parent:        c1c2e838e88c56ef38d590007ca3b588ca06f1fd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 23 09:57:46 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 23 10:09:58 2014 +0200

select: add FLD_UNCOMPARABLE flag for fields which can't be compared

A field where it has no meaning to do any type of comparison is the
implicit "help" or "?" field. The error given was a bit cryptic
before this patch, the FLD_UNCOMPARABLE flag makes it easier to identify
this situation anywhere in the code and provide much better error message.
This flag can be applied to other fields that may appear in the future -
mostly usable for implicit fields as they always have special purpose
(so we're not exporting it in libdevmapper for now - usual reporting
fields don't need this).

Before this patch:

$ vgs -S help=1
  dm_report_object: no data assigned to field help
  dm_report_object: no data assigned to field help

(...which is true actually, but let's provide something better...)

With this patch applied:

$vgs -S help=1
  Selection field is uncomparable: help.
  Selection syntax error at 'help=1'.

$vgs -S '(name=vg && help=1) || vg_size > 1g'
  Selection field is uncomparable: help.
  Selection syntax error at 'help=1) || vg_size > 1g'.
---
 libdm/libdm-report.c |   37 ++++++++++++++++++++++++-------------
 1 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index fd03052..3d16e5a 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -84,13 +84,14 @@ struct op_def {
 	const char *desc;
 };
 
-#define FLD_CMP_MASK	0x00FF0000
-#define FLD_CMP_EQUAL	0x00010000
-#define FLD_CMP_NOT	0x00020000
-#define FLD_CMP_GT	0x00040000
-#define FLD_CMP_LT	0x00080000
-#define FLD_CMP_REGEX	0x00100000
-#define FLD_CMP_NUMBER  0x00200000
+#define FLD_CMP_MASK		0x00FF0000
+#define FLD_CMP_UNCOMPARABLE	0x00010000
+#define FLD_CMP_EQUAL		0x00020000
+#define FLD_CMP_NOT		0x00040000
+#define FLD_CMP_GT		0x00080000
+#define FLD_CMP_LT		0x00100000
+#define FLD_CMP_REGEX		0x00200000
+#define FLD_CMP_NUMBER		0x00400000
 /*
  * #define FLD_CMP_STRING 0x00400000
  * We could defined FLD_CMP_STRING here for completeness here,
@@ -227,15 +228,15 @@ static const struct dm_report_object_type _implicit_common_report_types[] = {
 };
 
 static const struct dm_report_field_type _implicit_common_report_fields[] = {
-	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_HELP_ID, "Help", _no_report_fn, "Show help." },
-	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_HELP_ALT_ID, "Help", _no_report_fn, "Show help." },
+	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE, 0, 8, COMMON_FIELD_HELP_ID, "Help", _no_report_fn, "Show help." },
+	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE, 0, 8, COMMON_FIELD_HELP_ALT_ID, "Help", _no_report_fn, "Show help." },
 	{ 0, 0, 0, 0, "", "", 0, 0}
 };
 
 static const struct dm_report_field_type _implicit_common_report_fields_with_selection[] = {
 	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_SELECTED_ID, "Selected", _selected_disp, "Item passes selection criteria." },
-	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_HELP_ID, "Help", _no_report_fn, "Show help." },
-	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_HELP_ALT_ID, "Help", _no_report_fn, "Show help." },
+	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE, 0, 8, COMMON_FIELD_HELP_ID, "Help", _no_report_fn, "Show help." },
+	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE, 0, 8, COMMON_FIELD_HELP_ALT_ID, "Help", _no_report_fn, "Show help." },
 	{ 0, 0, 0, 0, "", "", 0, 0}
 };
 
@@ -2452,8 +2453,18 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		goto bad;
 	}
 
-	ft = implicit ? &_implicit_report_fields[field_num]
-		      : &rh->fields[field_num];
+	if (implicit) {
+		ft = &_implicit_report_fields[field_num];
+		if (ft->flags & FLD_CMP_UNCOMPARABLE) {
+			c = we[0];
+			tmp = (char *) we;
+			tmp[0] = '\0';
+			log_error("Selection field is uncomparable: %s.", ws);
+			tmp[0] = c;
+			goto bad;
+		}
+	} else
+		ft = &rh->fields[field_num];
 
 	/* comparison operator */
 	if (!(flags = _tok_op_cmp(we, &last))) {


