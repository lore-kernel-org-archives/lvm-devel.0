From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 25 Apr 2014 15:04:44 +0000 (UTC)
Subject: dev-prajnoha-condout - condout: make it possible to use condition using fields not reported on current output
Message-ID: <20140425150444.3C06560045@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=934701da9747613002bd3a9c51f16a97ae59e22e
Commit:        934701da9747613002bd3a9c51f16a97ae59e22e
Parent:        862c2a73ad04b6c57b376a9582344f918e3e81c1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 25 17:04:11 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 25 17:04:11 2014 +0200

condout: make it possible to use condition using fields not reported on current output

---
 lib/report/report.c  |    2 +-
 libdm/libdevmapper.h |    3 ++-
 libdm/libdm-report.c |    6 +++++-
 tools/dmsetup.c      |    3 ++-
 4 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index e18994c..2d48ec6 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1266,7 +1266,7 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		if (field_prefixes)
 			dm_report_set_output_field_name_prefix(rh, "lvm2_");
 
-		if (condition && !dm_report_set_output_condition(rh, condition)) {
+		if (condition && !dm_report_set_output_condition(rh, report_type, condition)) {
 			dm_report_free(rh);
 			rh = NULL;
 		}
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 450a797..fceec47 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1638,7 +1638,8 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 				 const char *sort_keys,
 				 void *private_data);
 int dm_report_object(struct dm_report *rh, void *object);
-int dm_report_set_output_condition(struct dm_report *rh, const char *condition);
+int dm_report_set_output_condition(struct dm_report *rh, uint32_t *report_types,
+				   const char *condition);
 int dm_report_output(struct dm_report *rh);
 void dm_report_free(struct dm_report *rh);
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 2d7daf2..3566c1d 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1173,6 +1173,7 @@ static struct field_condition *_create_field_condition(struct dm_report *rh,
 	if (!found) {
 		if (!(found = _add_field(rh, field_num, FLD_HIDDEN)))
 			return NULL;
+		rh->report_types |= rh->fields[field_num].type;
 	}
 
 	/*
@@ -1490,7 +1491,8 @@ error:
 	return NULL;
 }
 
-int dm_report_set_output_condition(struct dm_report *rh, const char *condition)
+int dm_report_set_output_condition(struct dm_report *rh, uint32_t *report_types,
+				   const char *condition)
 {
 	struct condition_node *root = NULL;
 	const char *fin, *next;
@@ -1518,6 +1520,8 @@ int dm_report_set_output_condition(struct dm_report *rh, const char *condition)
 		goto error;
 	}
 
+	if (report_types)
+		*report_types = rh->report_types;
 	rh->condition_root = root;
 	return 1;
 error:
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index acb36db..bae6291 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2934,7 +2934,8 @@ static int _report_init(const struct command *cmd)
 		dm_report_set_output_field_name_prefix(_report, "dm_");
 
 	if (_switches[CONDITION_ARG] &&
-	    !dm_report_set_output_condition(_report, _string_args[CONDITION_ARG])) {
+	    !dm_report_set_output_condition(_report, &_report_type,
+					    _string_args[CONDITION_ARG])) {
 		err("Failed to set report output condition.");
 		goto out;
 	}


