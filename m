From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 12 Aug 2015 21:04:23 +0000 (UTC)
Subject: master - dmstats: don't output column headings if report fails
Message-ID: <20150812210423.4459960F62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7995eedd3581407b030b0864202068b51dd1ef45
Commit:        7995eedd3581407b030b0864202068b51dd1ef45
Parent:        098528513f8c00d12f4ca5b5e87e4a932a6ef4f6
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Aug 12 22:02:23 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Aug 12 22:02:23 2015 +0100

dmstats: don't output column headings if report fails

If _stats_report fails (e.g. due to an invalid device on the
command line) destroy the _report to prevent stats columns headings
from being displayed.

This also requires a change in main to test the return from
_perform_command_for_all_repeatable_args inside the interval loop
and exit immediately in case of error.
---
 tools/dmsetup.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index e913a7e..dd2f153 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4692,6 +4692,10 @@ static int _stats_report(CMD_ARGS)
 
       out:
 	dm_task_destroy(dmt);
+	if (!r && _report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
 	return r;
 }
 
@@ -5838,6 +5842,9 @@ doit:
 					goto_out;
 			}
 		}
+
+		if (r)
+			break;
 	} while (--_count);
 
 out:


