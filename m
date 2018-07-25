From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 25 Jul 2018 05:37:52 -0400
Subject: 2018-06-01-stable - dmsetup: fix error propagation in _display_info_cols()
Message-ID: <201807250937.w6P9bqaw028802@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=951676a59eb2b3130abb9eec690206665708b0d0
Commit:        951676a59eb2b3130abb9eec690206665708b0d0
Parent:        4456d9aa77de7ac035ab975d87b0696e33370ab4
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jun 28 14:25:30 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jul 25 10:55:28 2018 +0200

dmsetup: fix error propagation in _display_info_cols()

Commit 3f35146 added a check on the value returned by the
_display_info_cols() function:

  1024         if (!_switches[COLS_ARG])
  1025                 _display_info_long(dmt, &info);
  1026         else
  1027                 r = _display_info_cols(dmt, &info);
  1028
  1029         return r;

This exposes a bug in the dmstats code in _display_info_cols:
the fact that a device has no regions is explicitly not an error
(and is documented as such in the code), but since the return
code is not changed before leaving the function it is now treated
as an error leading to:

  # dmstats list
  Command failed.

When no regions exist.

Set the return code to the correct value before returning.

(cherry picked from commit 29b9ccd261be025aaf75e58e5d2547e818ef22c3)
---
 tools/dmsetup.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 95a15dd..3cdf862 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -939,8 +939,10 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 			goto_out;
 
 		/* No regions to report is not an error */
-		if (!dm_stats_get_nr_regions(obj.stats))
+		if (!dm_stats_get_nr_regions(obj.stats)) {
+			r = 1;
 			goto out;
+		}
 	}
 
 	/* group report with no groups? */


