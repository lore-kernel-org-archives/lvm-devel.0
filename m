From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 9 Mar 2017 16:22:17 -0500
Subject: master - dmfilemapd: always set the program_id after listing regions
Message-ID: <201703092122.v29LMH1I001137@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ba11aa7eebb8367e4e0073683db06d53e8fe6e6
Commit:        1ba11aa7eebb8367e4e0073683db06d53e8fe6e6
Parent:        0104fd6c660d69b6e00bd906a2aed503bdb1ba5e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Mar 9 21:14:50 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 9 21:20:27 2017 +0000

dmfilemapd: always set the program_id after listing regions

The filemap daemon takes its program_id from the regions it is
managing: use DM_STATS_ALL_PROGRAMS when retrieving an initial
listing and then obtain the correct program_id from the group
leader.
---
 daemons/dmfilemapd/dmfilemapd.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index edf66fc..67f86d3 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -514,7 +514,7 @@ static void _filemap_monitor_destroy(struct filemap_monitor *fm)
 		_filemap_monitor_end_notify(fm);
 		_filemap_monitor_close_fd(fm);
 	}
-	dm_free(fm->program_id);
+	dm_free((void *) fm->program_id);
 }
 
 static int _filemap_monitor_check_same_file(int fd1, int fd2)
@@ -690,7 +690,7 @@ static int _dmfilemapd(struct filemap_monitor *fm)
 	if (!_filemap_monitor_set_notify(fm))
 		goto bad;
 
-	if (!dm_stats_list(dms, NULL)) {
+	if (!dm_stats_list(dms, DM_STATS_ALL_PROGRAMS)) {
 		log_error("Failed to list stats handle.");
 		goto bad;
 	}
@@ -705,6 +705,7 @@ static int _dmfilemapd(struct filemap_monitor *fm)
 		fm->program_id = dm_strdup(program_id);
 	else
 		fm->program_id = NULL;
+	dm_stats_set_program_id(dms, 1, program_id);
 
 	do {
 		if (!dm_stats_group_present(dms, fm->group_id)) {


