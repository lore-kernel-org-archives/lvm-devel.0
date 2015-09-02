From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  2 Sep 2015 19:49:49 +0000 (UTC)
Subject: master - libdm: reset report field widths in _destroy_rows()
Message-ID: <20150902194949.6E79060E15@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c4f3732c918c9d26fdaca42acdc92a02898dbe35
Commit:        c4f3732c918c9d26fdaca42acdc92a02898dbe35
Parent:        a9d954cb3cf974563d27ef1594d924c4de9c5eb9
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 24 11:38:17 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Sep 2 20:48:59 2015 +0100

libdm: reset report field widths in _destroy_rows()

For repeating reports field widths should be re-calculated for
each report interval. Not doing so will cause a single row with
wide field data to cause all subsequent rows to share the width:

Name                                      RgID ArID R/s     W/s    Histogram                                     Bounds
vg_hex-lv_home                               0    0 4522.00 834.00 0s:   991, 2ms:   152, 4ms:   161, 6ms:  4052 0s, 2ms, 4ms, 6ms
vg_hex-lv_swap                               0    0    0.00   0.00 0s: 0, 2ms: 0, 4ms: 0, 6ms: 0                 0s, 2ms, 4ms, 6ms
vg_hex-lv_root                               0    0 1754.00 683.00 0s:  369, 2ms:   65, 4ms:   90, 6ms: 1913     0s, 2ms, 4ms, 6ms
luks-79733921-3f68-4c92-9eb7-d0aca4c6ba3e    0    0 4522.00 868.00 0s:   985, 2ms:   152, 4ms:   161, 6ms:  4092 0s, 2ms, 4ms, 6ms
vg_hex-lv_images                             0    0    0.00   0.00 0s: 0, 2ms: 0, 4ms: 0, 6ms: 0                 0s, 2ms, 4ms, 6ms

Name                                      RgID ArID R/s     W/s    Histogram                                     Bounds
vg_hex-lv_home                               0    0    0.00   0.00 0s: 0, 2ms: 0, 4ms: 0, 6ms: 0                 0s, 2ms, 4ms, 6ms
vg_hex-lv_swap                               0    0    0.00   0.00 0s: 0, 2ms: 0, 4ms: 0, 6ms: 0                 0s, 2ms, 4ms, 6ms
vg_hex-lv_root                               0    0    0.00   2.00 0s: 1, 2ms: 0, 4ms: 0, 6ms: 1                 0s, 2ms, 4ms, 6ms
luks-79733921-3f68-4c92-9eb7-d0aca4c6ba3e    0    0    0.00   0.00 0s: 0, 2ms: 0, 4ms: 0, 6ms: 0                 0s, 2ms, 4ms, 6ms
vg_hex-lv_images                             0    0    0.00   0.00 0s: 0, 2ms: 0, 4ms: 0, 6ms: 0                 0s, 2ms, 4ms, 6ms
                                                                                                ^^^^^^^^^^^^^^^^^
This is especially significant for the current histogram fields:
depending on the time since the last clear operation the first
report iteration may contain very large values leading to a very
large minimum field width. Without resetting field widths this
large minimum field width value is used for all subsequent rows.
---
 libdm/libdm-report.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index b948073..2ebb69e 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -86,7 +86,8 @@ struct field_properties {
 	struct dm_list list;
 	uint32_t field_num;
 	uint32_t sort_posn;
-	int32_t width;
+	int32_t initial_width;
+	int32_t width; /* current width: adjusted by dm_report_object() */
 	const struct dm_report_object_type *type;
 	uint32_t flags;
 	int implicit;
@@ -774,7 +775,8 @@ static int _copy_field(struct dm_report *rh, struct field_properties *dest,
 							     : rh->fields;
 
 	dest->field_num = field_num;
-	dest->width = fields[field_num].width;
+	dest->initial_width = fields[field_num].width;
+	dest->width = fields[field_num].width; /* adjusted in _do_report_object() */
 	dest->flags = fields[field_num].flags & DM_REPORT_FIELD_MASK;
 	dest->implicit = implicit;
 
@@ -4178,6 +4180,13 @@ bad:
 	return 0;
 }
 
+static void _reset_field_props(struct dm_report *rh)
+{
+	struct field_properties *fp;
+	dm_list_iterate_items(fp, &rh->field_props)
+		fp->width = fp->initial_width;
+}
+
 static void _destroy_rows(struct dm_report *rh)
 {
 	/*
@@ -4189,6 +4198,9 @@ static void _destroy_rows(struct dm_report *rh)
 		dm_pool_free(rh->mem, rh->first_row);
 	rh->first_row = NULL;
 	dm_list_init(&rh->rows);
+
+	/* Reset field widths to original values. */
+	_reset_field_props(rh);
 }
 
 static int _output_as_rows(struct dm_report *rh)


