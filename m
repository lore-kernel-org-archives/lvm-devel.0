From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:04:25 -0400
Subject: master - dmstatus: check nr_regions ahead of find call
Message-ID: <201803151004.w2FA4P0B023581@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a082ce2613f3a9587b0109df0bbc3ebb7e6b1e75
Commit:        a082ce2613f3a9587b0109df0bbc3ebb7e6b1e75
Parent:        4c925692f58912fbe088a09cdbbc75bfa9e865f5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 14 21:01:22 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 10:54:19 2018 +0100

dmstatus: check nr_regions ahead of find call

Prevent call of dm_stats_populate(), when there has been no
stats region detected for a DM device.
Such skip is evaluated as 'correct' visit of stats call and
not causing 'dmstats' command failure.
---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 09e6fc0..2fafe74 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.147 - 
 =====================================
+  Avoid calling dm_stats_populat() for DM devices without any stats regions.
   Support DM_DEBUG_WITH_LINE_NUMBERS envvar for debug msg with source:line.
   Configured command for thin pool threshold handling gets whole environment.
   Fix tests for failing dm_snprintf() in stats code.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 64a45a6..95a15dd 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -910,6 +910,12 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		if (!(obj.stats = dm_stats_create(DM_STATS_PROGRAM_ID)))
 			goto_out;
 
+		if (!dm_stats_get_nr_regions(obj.stats)) {
+			log_debug("Skipping %s with no regions.", dm_task_get_name(dmt));
+			r = 1;
+			goto out;
+		}
+
 		dm_stats_bind_devno(obj.stats, info->major, info->minor);
 
 		if (!dm_stats_populate(obj.stats, _program_id, DM_STATS_REGIONS_ALL))


