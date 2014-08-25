From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Aug 2014 14:15:04 +0000 (UTC)
Subject: master - report: use dm_report_field_string_list_unordered for reporting lv_layout and lv_role fields
Message-ID: <20140825141504.D708560F96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d344c2e4509af34df219a0c9727902ab73b219c
Commit:        2d344c2e4509af34df219a0c9727902ab73b219c
Parent:        02dc3c773e6c8728b5df1dd7be8e1dc8c5f58e72
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 25 10:05:27 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 25 16:11:40 2014 +0200

report: use dm_report_field_string_list_unordered for reporting lv_layout and lv_role fields

This makes it a bit more readable since we can report more general
layouts/roles first and keywords describing the LV more precisely
afterwards in the list.
---
 lib/report/report.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 32aca88..84ca73b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -140,10 +140,11 @@ static int _field_set_value(struct dm_report_field *field, const void *data, con
 }
 
 static int _field_set_string_list(struct dm_report *rh, struct dm_report_field *field,
-				  const struct dm_list *list, void *private)
+				  const struct dm_list *list, void *private, int sorted)
 {
 	struct cmd_context *cmd = (struct cmd_context *) private;
-	return dm_report_field_string_list(rh, field, list, cmd->report_list_item_separator);
+	return sorted ? dm_report_field_string_list(rh, field, list, cmd->report_list_item_separator)
+		      : dm_report_field_string_list_unsorted(rh, field, list, cmd->report_list_item_separator);
 }
 
 /*
@@ -232,7 +233,7 @@ static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct dm_list *tagsl = (const struct dm_list *) data;
 
-	return _field_set_string_list(rh, field, tagsl, private);
+	return _field_set_string_list(rh, field, tagsl, private, 1);
 }
 
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -250,7 +251,7 @@ static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (!(list_lv_modules(mem, lv, modules)))
 		return_0;
 
-	return _field_set_string_list(rh, field, modules, private);
+	return _field_set_string_list(rh, field, modules, private, 1);
 }
 
 static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1331,7 +1332,7 @@ static int _lvlayout_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	return _field_set_string_list(rh, field, lv_layout, private);
+	return _field_set_string_list(rh, field, lv_layout, private, 0);
 }
 
 static int _lvrole_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1347,7 +1348,7 @@ static int _lvrole_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	return _field_set_string_list(rh, field, lv_role, private);
+	return _field_set_string_list(rh, field, lv_role, private, 0);
 }
 
 static int _lvinitialimagesync_disp(struct dm_report *rh, struct dm_pool *mem,


