From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Fri, 26 Aug 2022 13:08:50 +0000 (GMT)
Subject: main - report: values: add note about self-decriptive values to report
Message-ID: <20220826130850.CF4C63858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d70cfe6005165e173643954e6cd9eff745e4aa4
Commit:        8d70cfe6005165e173643954e6cd9eff745e4aa4
Parent:        e6b6a09f90f53a5cea3a712b2b84af57f4514a02
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 26 14:51:31 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 26 15:08:33 2022 +0200

report: values: add note about self-decriptive values to report

---
 lib/report/report.c | 27 +++++++++++++++++++++++++++
 lib/report/values.h | 27 +++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/lib/report/report.c b/lib/report/report.c
index 8a5122ff9..f666ca842 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -29,6 +29,33 @@
 #include <float.h> /* DBL_MAX */
 #include <time.h>
 
+/*
+ * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
+ * IMPORTANT NOTE ABOUT ADDING A NEW VALUE FOR REPORTING
+ * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
+ *
+ * When adding a new string value to report, try to keep it
+ * self-descriptive so when it's printed even without the header,
+ * we can still deduce what it is actually reporting.
+ *
+ * If you need more than one descriptive string to mean the same value,
+ * please define them as reserved values in values.h.
+ *
+ * The first reserved value is the one that is printed in reports (unless
+ * it's a binary value and we have report/binary_values_as_numeric=1 config
+ * option used OR --binary command line option is used OR we're using an
+ * output format which must always print binary values in numeric way,
+ * like json_std output format.
+ *
+ * All the other (2nd and further) listed reserved names are synonyms which
+ * may be also used in selection (-S|--select).
+ *
+ * Also, always use proper *_disp functions to display each type of value
+ * properly. For example, in case of binary values, you should use
+ * _binary_disp so that we can always switch between numerical (0/1/-1) and
+ * string representation while reporting the value.
+ */
+
 struct lvm_report_object {
 	struct volume_group *vg;
 	struct lv_with_info_and_seg_status *lvdm;
diff --git a/lib/report/values.h b/lib/report/values.h
index 9b98c229e..71175fa6e 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -45,6 +45,33 @@
 
 /* *INDENT-OFF* */
 
+/*
+ * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
+ * IMPORTANT NOTE ABOUT ADDING A NEW VALUE FOR REPORTING
+ * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
+ *
+ * When adding a new string value to report, try to keep it
+ * self-descriptive so when it's printed even without the header,
+ * we can still deduce what it is actually reporting.
+ *
+ * If you need more than one descriptive string to mean the same value,
+ * please define them as reserved values in values.h.
+ *
+ * The first reserved value is the one that is printed in reports (unless
+ * it's a binary value and we have report/binary_values_as_numeric=1 config
+ * option used OR --binary command line option is used OR we're using an
+ * output format which must always print binary values in numeric way,
+ * like json_std output format.
+ *
+ * All the other (2nd and further) listed reserved names are synonyms which
+ * may be also used in selection (-S|--select).
+ *
+ * Also, always use proper *_disp functions to display each type of value
+ * properly. For example, in case of binary values, you should use
+ * _binary_disp so that we can always switch between numerical (0/1/-1) and
+ * string representation while reporting the value.
+ */
+
 /* Per-type reserved values usable for all fields of certain type. */
 TYPE_RESERVED_VALUE(NUM, NOFLAG, num_undef_64, "Reserved value for undefined numeric value.", UINT64_C(-1), "-1", "unknown", "undefined", "undef")
 

