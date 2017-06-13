From: Bryn Reeves <bmr@sourceware.org>
Date: Tue, 13 Jun 2017 14:47:52 -0400
Subject: master - dmfilemapd: update file block count at daemon start
Message-ID: <201706131847.v5DIlqQ0028910@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0cb628dfe2980b45fb7db5edd2f197d23905b02e
Commit:        0cb628dfe2980b45fb7db5edd2f197d23905b02e
Parent:        744f2920dbb03c391a2d4981ed6c93af85121e7e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jun 7 19:26:09 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jun 13 19:46:41 2017 +0100

dmfilemapd: update file block count at daemon start

The file block count stored in the filemap_monitor was lazily
initialised at the time of the first check. This causes problems
in the case that the file has been truncated between this time and
the time the daemon started: the initial block count and current
block count match and the daemon fails to detect a change.

Separate the setting of the block count from the check and make a
call to update the value at the start of _dmfilemapd().
---
 daemons/dmfilemapd/dmfilemapd.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 2637bd2..0dbdefc 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -357,30 +357,33 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 	return 1;
 }
 
-static int _filemap_fd_check_changed(struct filemap_monitor *fm)
+static int _filemap_fd_update_blocks(struct filemap_monitor *fm)
 {
-	int64_t blocks, old_blocks;
 	struct stat buf;
 
 	if (fm->fd < 0) {
 		log_error("Filemap fd is not open.");
-		return -1;
+		return 0;
 	}
 
 	if (fstat(fm->fd, &buf)) {
 		log_error("Failed to fstat filemap file descriptor.");
-		return -1;
+		return 0;
 	}
 
-	blocks = buf.st_blocks;
+	fm->blocks = buf.st_blocks;
 
-	/* first check? */
-	if (fm->blocks < 0)
-		old_blocks = buf.st_blocks;
-	else
-		old_blocks = fm->blocks;
+	return 1;
+}
 
-	fm->blocks = blocks;
+static int _filemap_fd_check_changed(struct filemap_monitor *fm)
+{
+	int64_t old_blocks;
+
+	old_blocks = fm->blocks;
+
+	if (!_filemap_fd_update_blocks(fm))
+		return -1;
 
 	return (fm->blocks != old_blocks);
 }
@@ -714,6 +717,9 @@ static int _dmfilemapd(struct filemap_monitor *fm)
 	if (!_filemap_monitor_set_notify(fm))
 		goto bad;
 
+	if (!_filemap_fd_update_blocks(fm))
+		goto bad;
+
 	if (!dm_stats_list(dms, DM_STATS_ALL_PROGRAMS)) {
 		log_error("Failed to list stats handle.");
 		goto bad;


