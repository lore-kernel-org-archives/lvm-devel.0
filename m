From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 1 Nov 2018 13:01:26 -0400
Subject: master - dmsetup: fix stats report command output
Message-ID: <201811011701.wA1H1Q88009389@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=925aaf0b874fd92aec1b34f42d23987f65205ff9
Commit:        925aaf0b874fd92aec1b34f42d23987f65205ff9
Parent:        19f2105b87773047854ef172de8fc48da110b2fa
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Nov 1 16:49:05 2018 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Nov 1 17:00:06 2018 +0000

dmsetup: fix stats report command output

Since the stats handle is neither bound nor listed before the
attempt to call dm_stats_get_nr_regions(), it will always return
zero: this prevents reporting of any dmstats regions on any
device.

Remove the dm_stats_get_nr_regions() check and instead rely on
the correct return status from dm_stats_populate() which only
returns 0 in the case that there are regions to inspect (and
which logs a specific error for all other cases).

Reported-by: Bryan Gurney <bgurney@redhat.com>
---
 libdm/dm-tools/dmsetup.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 835fdcd..93714ac 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -914,17 +914,13 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		if (!(obj.stats = dm_stats_create(DM_STATS_PROGRAM_ID)))
 			goto_out;
 
-		if (!dm_stats_get_nr_regions(obj.stats)) {
-			log_debug("Skipping %s with no regions.", dm_task_get_name(dmt));
+		dm_stats_bind_devno(obj.stats, info->major, info->minor);
+
+		if (!dm_stats_populate(obj.stats, _program_id, DM_STATS_REGIONS_ALL)) {
 			r = 1;
 			goto out;
 		}
 
-		dm_stats_bind_devno(obj.stats, info->major, info->minor);
-
-		if (!dm_stats_populate(obj.stats, _program_id, DM_STATS_REGIONS_ALL))
-			goto_out;
-
 		/* Update timestamps and handle end-of-interval accounting. */
 		_update_interval_times();
 


