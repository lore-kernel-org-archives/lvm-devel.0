From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 13:10:08 +0000 (UTC)
Subject: master - dmstats: fix interval number reporting with --count=0
Message-ID: <20161218131008.5850360EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a4750d76c9930a6e4a181ab664f0cac4d1a400b
Commit:        5a4750d76c9930a6e4a181ab664f0cac4d1a400b
Parent:        5635cd3b0337ac854a82a1a15cef2609c2091e6c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 12:58:03 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 13:03:45 2016 +0000

dmstats: fix interval number reporting with --count=0

When --count=0 interval numbers are miscalculated:

Interval     #18446744069414584325     time delta:    999920887ns
Interval     #18446744069414584325   current err:       -79113ns
End interval #18446744069414584325  duration:    999920887ns

This is because the command line argument is cast through the
uint32_t type, and fixed to UINT32_MAX:

  _count = ((uint32_t)_int_args[COUNT_ARG]) ? : UINT32_MAX;

We also need to handle --count=0 specially when calculating the
interval number: since intervals count from #1, this must account
for the implicit "minus one" when converting from zero to the
UINT64_MAX value used (which is too large to store in _int_args).
---
 tools/dmsetup.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b1967db..06d609b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -264,7 +264,7 @@ static struct dm_tree *_dtree;
 static struct dm_report *_report;
 static report_type_t _report_type;
 static dev_name_t _dev_name_type;
-static uint32_t _count = 1; /* count of repeating reports */
+static uint64_t _count = 1; /* count of repeating reports */
 static struct dm_timestamp *_initial_timestamp = NULL;
 static uint64_t _disp_factor = 512; /* display sizes in sectors */
 static char _disp_units = 's';
@@ -557,7 +557,8 @@ static void _destroy_split_name(struct dm_split_name *split_name)
  */
 static uint64_t _interval_num(void)
 {
-	return 1 + (uint64_t) _int_args[COUNT_ARG] - _count;
+	uint64_t count_arg = _int_args[COUNT_ARG];
+	return ((uint64_t) _int_args[COUNT_ARG] - _count) + !!count_arg;
 }
 
 #ifdef HAVE_SYS_TIMERFD_H
@@ -6873,10 +6874,10 @@ unknown:
 			goto_out;
 	}
 
-	if (_switches[COUNT_ARG])
-		_count = ((uint32_t)_int_args[COUNT_ARG]) ? : UINT32_MAX;
-	else if (_switches[INTERVAL_ARG])
-		_count = UINT32_MAX;
+	if (_switches[COUNT_ARG] && _int_args[COUNT_ARG])
+		_count = (uint64_t)_int_args[COUNT_ARG];
+	else if (_switches[COUNT_ARG] || _switches[INTERVAL_ARG])
+		_count = UINT64_MAX;
 
 	if (_switches[UNITS_ARG]) {
 		_disp_factor = _factor_from_units(_string_args[UNITS_ARG],


