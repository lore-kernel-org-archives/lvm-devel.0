From: Bryn Reeves <bmr@sourceware.org>
Date: Tue, 13 Jun 2017 14:47:56 -0400
Subject: master - dmfilemapd: do not wait if file has been truncated
Message-ID: <201706131847.v5DIluCO028922@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a094350e044100fdfb2270a18085e42e6f5ba3a
Commit:        9a094350e044100fdfb2270a18085e42e6f5ba3a
Parent:        0cb628dfe2980b45fb7db5edd2f197d23905b02e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jun 7 19:29:16 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jun 13 19:46:41 2017 +0100

dmfilemapd: do not wait if file has been truncated

---
 daemons/dmfilemapd/dmfilemapd.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 0dbdefc..43ae970 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -686,7 +686,10 @@ static int _update_regions(struct dm_stats *dms, struct filemap_monitor *fm)
 	for (region = regions; *region != DM_STATS_REGIONS_ALL; region++)
 		nr_regions++;
 
-	if (regions[0] != fm->group_id) {
+	if (!nr_regions)
+		log_warn("File contains no extents: exiting.");
+
+	if (nr_regions && (regions[0] != fm->group_id)) {
 		log_warn("group_id changed from " FMTu64 " to " FMTu64,
 			 fm->group_id, regions[0]);
 		fm->group_id = regions[0];
@@ -753,17 +756,16 @@ static int _dmfilemapd(struct filemap_monitor *fm)
 		if ((check = _filemap_fd_check_changed(fm)) < 0)
 			goto bad;
 
-		if (!check)
-			goto wait;
-
-		if (!_update_regions(dms, fm))
+		if (check && !_update_regions(dms, fm))
 			goto bad;
 
+		running = !!fm->nr_regions;
+		if (!running)
+			continue;
+
 wait:
 		_filemap_monitor_wait(FILEMAPD_WAIT_USECS);
 
-		running = !!fm->nr_regions;
-
 		/* mode=inode termination condions */
 		if (fm->mode == DM_FILEMAPD_FOLLOW_INODE) {
 			if (!_filemap_monitor_check_file_unlinked(fm))


