From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 28 Jun 2018 09:26:12 -0400
Subject: master - dmsetup: fix error propagation in _display_info_cols()
Message-ID: <201806281326.w5SDQCDN021126@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=29b9ccd261be025aaf75e58e5d2547e818ef22c3
Commit:        29b9ccd261be025aaf75e58e5d2547e818ef22c3
Parent:        f96fd9961d1a80999a38b45c1d173e3df1de83e5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jun 28 14:25:30 2018 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Jun 28 14:25:30 2018 +0100

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
---
 libdm/dm-tools/dmsetup.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 44386a6..fb1a574 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -943,8 +943,10 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 			goto_out;
 
 		/* No regions to report is not an error */
-		if (!dm_stats_get_nr_regions(obj.stats))
+		if (!dm_stats_get_nr_regions(obj.stats)) {
+			r = 1;
 			goto out;
+		}
 	}
 
 	/* group report with no groups? */


