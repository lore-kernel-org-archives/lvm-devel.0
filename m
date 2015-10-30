From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:32 +0000 (UTC)
Subject: master - report: add report_get_field_prefix function
Message-ID: <20151030145232.559BE609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bb4d3fa7a70881b72ddf61cba02760b89cf07b53
Commit:        bb4d3fa7a70881b72ddf61cba02760b89cf07b53
Parent:        3e18b101a0845f826de29cfd0c554c5e2be2baa5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 22 13:27:59 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

report: add report_get_field_prefix function

---
 lib/report/report.c |   15 +++++++++++++++
 lib/report/report.h |    1 +
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index dea66ee..911c96e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3396,6 +3396,21 @@ void *report_init_for_selection(struct cmd_context *cmd,
 					     cmd);
 }
 
+const char *report_get_field_prefix(report_type_t report_type_id)
+{
+	const struct dm_report_object_type *report_types, *report_type;
+
+	report_types = report_type_id & DEVTYPES ? _devtypes_report_types
+						 : _report_types;
+
+	for (report_type = report_types; report_type->id; report_type++) {
+		if (report_type_id & report_type->id)
+			return report_type->prefix;
+	}
+
+	return "";
+}
+
 /*
  * Create a row of data for an object
  */
diff --git a/lib/report/report.h b/lib/report/report.h
index 84c5f91..6c8b026 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -71,6 +71,7 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  int quoted, int columns_as_rows, const char *selection);
 void *report_init_for_selection(struct cmd_context *cmd, report_type_t *report_type,
 				const char *selection);
+const char *report_get_field_prefix(report_type_t report_type);
 int report_for_selection(struct cmd_context *cmd,
 			 struct selection_handle *sh,
 			 struct physical_volume *pv,


