From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Nov 2013 11:39:26 +0000 (UTC)
Subject: master - report: add wrappers to set values and percents
Message-ID: <20131115113926.83C4A6135C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49ccf44f4505242262bf35f7e226d2791aad9397
Commit:        49ccf44f4505242262bf35f7e226d2791aad9397
Parent:        322e7b3060e79e62708f7936f140386d64704878
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 23 10:02:01 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 11:05:00 2013 +0100

report: add wrappers to set values and percents

Add wrapper function for dm_report_field_set_value() which returns void
and return 1, so the code could be shorter.

Add wrapper function for percent display _field_set_percent().
---
 WHATS_NEW           |    1 +
 lib/report/report.c |   37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b6f51e1..b190ca4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Simplify reporting code.
 
 Version 2.02.104 - 13th November 2013
 =====================================
diff --git a/lib/report/report.c b/lib/report/report.c
index 46edf56..49a6b8a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -38,6 +38,43 @@ static const uint64_t _minusone64 = UINT64_C(-1);
 static const int32_t _minusone32 = INT32_C(-1);
 static const uint64_t _zero64 = UINT64_C(0);
 
+static int _field_set_value(struct dm_report_field *field, const void *data, const void *sort)
+{
+	dm_report_field_set_value(field, data, sort);
+
+	return 1;
+}
+
+static int _field_set_percent(struct dm_report_field *field,
+			      struct dm_pool *mem,
+			      percent_t percent)
+{
+	char *repstr;
+	uint64_t *sortval;
+
+	if (percent == PERCENT_INVALID)
+		// FIXME  maybe use here '--'?
+		return _field_set_value(field, "", &_minusone64);
+
+	if (!(repstr = dm_pool_alloc(mem, 8)) ||
+	    !(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
+		if (repstr)
+			dm_pool_free(mem, repstr);
+		log_error("dm_pool_alloc failed.");
+		return 0;
+	}
+
+	if (dm_snprintf(repstr, 7, "%.2f", percent_to_float(percent)) < 0) {
+		dm_pool_free(mem, repstr);
+		log_error("Percentage too large.");
+		return 0;
+	}
+
+	*sortval = (uint64_t)(percent * 1000.f);
+
+	return _field_set_value(field, repstr, sortval);
+}
+
 /*
  * Data-munging functions to prepare each data type for display and sorting
  */


