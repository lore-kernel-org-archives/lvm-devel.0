From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 15 Jun 2013 00:31:10 +0000 (UTC)
Subject: master - report: revert lvs origin_size sort order change
Message-ID: <20130615003111.0231360D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=538acd56f1a3cd439028e0b9c9d6106cb820228c
Commit:        538acd56f1a3cd439028e0b9c9d6106cb820228c
Parent:        53b405093b7c13235589b2778f9236e2aabcae61
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jun 15 01:24:16 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jun 15 01:24:16 2013 +0100

report: revert lvs origin_size sort order change

Reinstate the previous sort order for origin_size, so that LVs with
an empty origin_size continue to appear at the start of the list
not the end.

Ref. 9d445f371c7658969d6580748233dc33c3ba0453
---
 lib/report/report.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 2459ad0..47b3a33 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -35,6 +35,7 @@ struct lvm_report_object {
 
 static const uint64_t _minusone64 = UINT64_C(-1);
 static const int32_t _minusone32 = INT32_C(-1);
+static const uint64_t _zero64 = UINT64_C(0);
 
 /*
  * Data-munging functions to prepare each data type for display and sorting
@@ -608,7 +609,7 @@ static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	uint64_t size;
 
 	if (!(size = lv_origin_size(lv))) {
-		dm_report_field_set_value(field, "", NULL);
+		dm_report_field_set_value(field, "", &_zero64);
 		return 1;
 	}
 


