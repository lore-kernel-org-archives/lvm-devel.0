From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 9 Mar 2017 12:53:50 -0500
Subject: master - libdm: remove unnecessary backtrace in _stats_group_id_present()
Message-ID: <201703091753.v29HroUM019145@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c98868181fa3ee0816d525ef186c1059a46f1d0b
Commit:        c98868181fa3ee0816d525ef186c1059a46f1d0b
Parent:        fab088cbc79211966f654245299347261fd5cb9f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Mar 9 17:33:02 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 9 17:53:15 2017 +0000

libdm: remove unnecessary backtrace in _stats_group_id_present()

It's not an error to call dm_stats_group_present() on a handle
that contains no regions.

This causes dmfilemap to log a false backtrace during shutdown
if all regions are removed from the corresponding device:

  exiting _filemap_monitor_get_events() with deleted=0, check=0
  waiting for FILEMAPD_WAIT
  dm message   (253:1) [ opencount flush ]  @stats_list dmstats [32768] (*1)
  <backtrace>
  Filemap group removed: exiting.

Change this to only emit a backtrace if the handle is NULL.
---
 libdm/libdm-stats.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 3f6730e..f0a7dbf 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -264,9 +264,12 @@ static int _stats_group_id_present(const struct dm_stats *dms, uint64_t id)
 	if (id == DM_STATS_GROUP_NOT_PRESENT)
 		return 0;
 
-	if (!dms || !dms->regions)
+	if (!dms)
 		return_0;
 
+	if (!dms->regions)
+		return 0;
+
 	if (id > dms->max_region)
 		return 0;
 


