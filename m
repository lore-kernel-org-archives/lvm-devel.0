From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:02 +0000 (GMT)
Subject: main - libdm: report: add DM_REPORT_GROUP_JSON_STD group
Message-ID: <20220811110602.EFAA23857BAB@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02f015990b2d077f304e19c9ff11728d4480bee8
Commit:        02f015990b2d077f304e19c9ff11728d4480bee8
Parent:        2fc52b6c41172fc4ae15e736fae095aa681ff03a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 15:06:58 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

libdm: report: add DM_REPORT_GROUP_JSON_STD group

The original JSON formatting will be still available using the original
DM_REPORT_GROUP_JSON identifier. Subsequent patches will add enhancements
to JSON formatting code so that it adheres more to JSON standard - this
will be identified by new DM_REPORT_GROUP_JSON_STD identifier.
---
 device_mapper/all.h          |  3 ++-
 device_mapper/libdm-report.c | 13 +++++++++++--
 libdm/libdevmapper.h         |  3 ++-
 libdm/libdm-report.c         | 13 +++++++++++--
 4 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index 34d65885e..b70a8f29c 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -1983,7 +1983,8 @@ struct dm_report_group;
 typedef enum {
 	DM_REPORT_GROUP_SINGLE,
 	DM_REPORT_GROUP_BASIC,
-	DM_REPORT_GROUP_JSON
+	DM_REPORT_GROUP_JSON,
+	DM_REPORT_GROUP_JSON_STD
 } dm_report_group_type_t;
 
 struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data);
diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index 13a8e46b1..2e1f443f6 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -4369,10 +4369,17 @@ static int _is_basic_report(struct dm_report *rh)
 	       (rh->group_item->group->type == DM_REPORT_GROUP_BASIC);
 }
 
+static int _is_json_std_report(struct dm_report *rh)
+{
+	return rh->group_item &&
+	       rh->group_item->group->type == DM_REPORT_GROUP_JSON_STD;
+}
+
 static int _is_json_report(struct dm_report *rh)
 {
 	return rh->group_item &&
-	       (rh->group_item->group->type == DM_REPORT_GROUP_JSON);
+	       (rh->group_item->group->type == DM_REPORT_GROUP_JSON ||
+		rh->group_item->group->type == DM_REPORT_GROUP_JSON_STD);
 }
 
 /*
@@ -4983,6 +4990,7 @@ int dm_report_group_push(struct dm_report_group *group, struct dm_report *report
 				goto_bad;
 			break;
 		case DM_REPORT_GROUP_JSON:
+		case DM_REPORT_GROUP_JSON_STD:
 			if (!_report_group_push_json(item, data))
 				goto_bad;
 			break;
@@ -5046,6 +5054,7 @@ int dm_report_group_pop(struct dm_report_group *group)
 				return_0;
 			break;
 		case DM_REPORT_GROUP_JSON:
+		case DM_REPORT_GROUP_JSON_STD:
 			if (!_report_group_pop_json(item))
 				return_0;
 			break;
@@ -5082,7 +5091,7 @@ int dm_report_group_output_and_pop_all(struct dm_report_group *group)
 			return_0;
 	}
 
-	if (group->type == DM_REPORT_GROUP_JSON) {
+	if (group->type == DM_REPORT_GROUP_JSON || group->type == DM_REPORT_GROUP_JSON_STD) {
 		_json_output_start(group);
 		log_print(JSON_OBJECT_END);
 		group->indent -= JSON_INDENT_UNIT;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e9412da7d..c1c6cb40e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -3170,7 +3170,8 @@ struct dm_report_group;
 typedef enum dm_report_group_type_e {
 	DM_REPORT_GROUP_SINGLE,
 	DM_REPORT_GROUP_BASIC,
-	DM_REPORT_GROUP_JSON
+	DM_REPORT_GROUP_JSON,
+	DM_REPORT_GROUP_JSON_STD
 } dm_report_group_type_t;
 
 struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data);
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index f3bf628a5..b43ac4298 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4368,10 +4368,17 @@ static int _is_basic_report(struct dm_report *rh)
 	       (rh->group_item->group->type == DM_REPORT_GROUP_BASIC);
 }
 
+static int _is_json_std_report(struct dm_report *rh)
+{
+	return rh->group_item &&
+	       rh->group_item->group->type == DM_REPORT_GROUP_JSON_STD;
+}
+
 static int _is_json_report(struct dm_report *rh)
 {
 	return rh->group_item &&
-	       (rh->group_item->group->type == DM_REPORT_GROUP_JSON);
+	       (rh->group_item->group->type == DM_REPORT_GROUP_JSON ||
+		rh->group_item->group->type == DM_REPORT_GROUP_JSON_STD);
 }
 
 /*
@@ -4982,6 +4989,7 @@ int dm_report_group_push(struct dm_report_group *group, struct dm_report *report
 				goto_bad;
 			break;
 		case DM_REPORT_GROUP_JSON:
+		case DM_REPORT_GROUP_JSON_STD:
 			if (!_report_group_push_json(item, data))
 				goto_bad;
 			break;
@@ -5045,6 +5053,7 @@ int dm_report_group_pop(struct dm_report_group *group)
 				return_0;
 			break;
 		case DM_REPORT_GROUP_JSON:
+		case DM_REPORT_GROUP_JSON_STD:
 			if (!_report_group_pop_json(item))
 				return_0;
 			break;
@@ -5081,7 +5090,7 @@ int dm_report_group_output_and_pop_all(struct dm_report_group *group)
 			return_0;
 	}
 
-	if (group->type == DM_REPORT_GROUP_JSON) {
+	if (group->type == DM_REPORT_GROUP_JSON || group->type == DM_REPORT_GROUP_JSON_STD) {
 		_json_output_start(group);
 		log_print(JSON_OBJECT_END);
 		group->indent -= JSON_INDENT_UNIT;

