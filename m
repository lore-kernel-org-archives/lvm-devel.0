From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 24 Nov 2014 09:48:32 +0000 (UTC)
Subject: master - report: add some comments about how string list is stored internally
Message-ID: <20141124094833.0005C60DA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9601b8353a7d7ccba70638800630065175e6f03
Commit:        b9601b8353a7d7ccba70638800630065175e6f03
Parent:        ced0c17f2179af623cfec72e5a52f93471cda676
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Nov 24 10:48:01 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Nov 24 10:48:01 2014 +0100

report: add some comments about how string list is stored internally

---
 libdm/libdm-report.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 0dfbc30..88a429b 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -368,6 +368,21 @@ static int _report_field_string_list(struct dm_report *rh,
 	 * position and length for each list element withing the report_string.
 	 * The first element stores number of elements in 'len' (therefore
 	 * list_size + 1 is used below for the extra element).
+	 * For example, with this input:
+	 *   sort = 0;  (we don't want to report sorted)
+	 *   report_string = "abc,xy,defgh";  (this is reported)
+	 *
+	 * ...we end up with:
+	 *   sort_value->value = report_string; (we'll use the original report_string for indices)
+	 *   sort_value->items[0] = {0,3};  (we have 3 items)
+	 *   sort_value->items[1] = {0,3};  ("abc")
+	 *   sort_value->items[2] = {7,4};  ("defgh")
+	 *   sort_value->items[3] = {4,2};  ("xy")
+	 *
+	 *   The items alone are always sorted while in report_string they can be
+	 *   sorted or not (based on "sort" arg) - it depends on how we prefer to
+	 *   display the list. Having items sorted internally helps with searching
+	 *   through them.
 	 */
 	if (!(sort_value->items = dm_pool_zalloc(rh->mem, (list_size + 1) * sizeof(struct str_list_sort_value_item)))) {
 		log_error("dm_report_fiel_string_list: dm_pool_zalloc failed for sort value items");


