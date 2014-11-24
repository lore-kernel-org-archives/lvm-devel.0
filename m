From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 24 Nov 2014 12:14:44 +0000 (UTC)
Subject: master - report: add some comments about how string list is stored internally
Message-ID: <20141124121444.679CC60D80@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb220314ec787bd8f0855b055e1b3bba7368dd26
Commit:        fb220314ec787bd8f0855b055e1b3bba7368dd26
Parent:        b9601b8353a7d7ccba70638800630065175e6f03
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Nov 24 13:14:33 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Nov 24 13:14:33 2014 +0100

report: add some comments about how string list is stored internally

---
 libdm/libdm-report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 88a429b..470c2d1 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -376,7 +376,7 @@ static int _report_field_string_list(struct dm_report *rh,
 	 *   sort_value->value = report_string; (we'll use the original report_string for indices)
 	 *   sort_value->items[0] = {0,3};  (we have 3 items)
 	 *   sort_value->items[1] = {0,3};  ("abc")
-	 *   sort_value->items[2] = {7,4};  ("defgh")
+	 *   sort_value->items[2] = {7,5};  ("defgh")
 	 *   sort_value->items[3] = {4,2};  ("xy")
 	 *
 	 *   The items alone are always sorted while in report_string they can be


