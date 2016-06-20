From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:12 +0000 (UTC)
Subject: master - libdm: report: implement DM_REPORT_GROUP_SINGLE for a group containing single report only
Message-ID: <20160620094012.C0EB460FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9fe57db1c285ef7052a1054891f5eb7dbbb01b2
Commit:        a9fe57db1c285ef7052a1054891f5eb7dbbb01b2
Parent:        9c8f912ea79d9b836c814b3d12cc331de634617e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 16 11:23:56 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 10:42:18 2016 +0200

libdm: report: implement DM_REPORT_GROUP_SINGLE for a group containing single report only

There's no change in output for this report group type - with this type,
we only make sure there's always only one report in a group at a time,
not more.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c16f0c1..fdae74b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.128 -
 =================================
+  Introduce DM_REPORT_GROUP_SINGLE for report group having single report only.
   Add dm_report_group_{create,push,pop,destroy} to support report grouping.
 
 Version 1.02.127 - 11th June 2016
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index ab87ba7..7ea5ebf 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4485,6 +4485,11 @@ out:
 	return r;
 }
 
+static int _report_group_create_single(struct dm_report_group *group)
+{
+	return 1;
+}
+
 struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data)
 {
 	struct dm_report_group *group;
@@ -4513,6 +4518,10 @@ struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void
 	dm_list_add_h(&group->items, &item->list);
 
 	switch (type) {
+		case DM_REPORT_GROUP_SINGLE:
+			if (!_report_group_create_single(group))
+				goto_bad;
+			break;
 		default:
 			goto_bad;
 	}
@@ -4523,6 +4532,25 @@ bad:
 	return NULL;
 }
 
+static int _report_group_push_single(struct report_group_item *item, void *data)
+{
+	struct report_group_item *item_iter;
+	unsigned count = 0;
+
+	dm_list_iterate_items(item_iter, &item->group->items) {
+		if (item_iter->report)
+			count++;
+	}
+
+	if (count > 1) {
+		log_error("dm_report: unable to add more than one report "
+			  "to current report group");
+		return 0;
+	}
+
+	return 1;
+}
+
 int dm_report_group_push(struct dm_report_group *group, struct dm_report *report, void *data)
 {
 	struct report_group_item *item, *tmp_item;
@@ -4552,6 +4580,10 @@ int dm_report_group_push(struct dm_report_group *group, struct dm_report *report
 	dm_list_add_h(&group->items, &item->list);
 
 	switch (group->type) {
+		case DM_REPORT_GROUP_SINGLE:
+			if (!_report_group_push_single(item, data))
+				goto_bad;
+			break;
 		default:
 			goto_bad;
 	}
@@ -4563,6 +4595,11 @@ bad:
 	return 0;
 }
 
+static int _report_group_pop_single(struct report_group_item *item)
+{
+	return 1;
+}
+
 int dm_report_group_pop(struct dm_report_group *group)
 {
 	struct report_group_item *item;
@@ -4576,6 +4613,10 @@ int dm_report_group_pop(struct dm_report_group *group)
 	}
 
 	switch (group->type) {
+		case DM_REPORT_GROUP_SINGLE:
+			if (!_report_group_pop_single(item))
+				return_0;
+			break;
 		default:
 			return 0;
         }
@@ -4594,6 +4635,11 @@ int dm_report_group_pop(struct dm_report_group *group)
 	return 1;
 }
 
+static int _report_group_destroy_single(void)
+{
+	return 1;
+}
+
 int dm_report_group_destroy(struct dm_report_group *group)
 {
 	struct report_group_item *item, *tmp_item;
@@ -4610,6 +4656,10 @@ int dm_report_group_destroy(struct dm_report_group *group)
 	}
 
 	switch (group->type) {
+		case DM_REPORT_GROUP_SINGLE:
+			if (!_report_group_destroy_single())
+				goto_out;
+			break;
 		default:
 			goto_out;
         }


