From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:15 -0400
Subject: master - dmfilemapd: always close check file descriptor (coverity)
Message-ID: <201703292016.v2TKGFJJ000759@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70bb72667889a2d6f250437e5db247eb111ca1aa
Commit:        70bb72667889a2d6f250437e5db247eb111ca1aa
Parent:        43fdbb8aeb78f9ada5dc135fa421c344c8e998d3
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 17:04:55 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:33:53 2017 +0100

dmfilemapd: always close check file descriptor (coverity)

The daemon opens a new file descriptor from fm->path when checking
for an unlinked file with mode=inode. Ensure that it is always
closed even if the same file test fails.
---
 daemons/dmfilemapd/dmfilemapd.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 0cb0ad7..3fd76b7 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -566,12 +566,14 @@ static int _filemap_monitor_check_file_unlinked(struct filemap_monitor *fm)
 	if ((fd = open(fm->path, O_RDONLY)) < 0)
 		goto check_unlinked;
 
-	if ((same = _filemap_monitor_check_same_file(fm->fd, fd)) < 0)
-		return 0;
+	same = _filemap_monitor_check_same_file(fm->fd, fd);
 
 	if (close(fd))
 		log_error("Error closing fd %d", fd);
 
+	if (same < 0)
+		return 0;
+
 	if (same)
 		return 1;
 


