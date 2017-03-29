From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:25 -0400
Subject: master - dmfilemapd: always close link check file descriptor (coverity)
Message-ID: <201703292016.v2TKGPRn000780@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8658bbe3eed38183554643f93f4c23718fd24827
Commit:        8658bbe3eed38183554643f93f4c23718fd24827
Parent:        7db51a6bed8704ec634b44b4c5bd1dc35fdae86b
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 17:22:18 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:34:11 2017 +0100

dmfilemapd: always close link check file descriptor (coverity)

Similar to 40fb91a, but for the file descriptor opened using the
link path reported by /proc/<self>/fd/<fd>.

The daemon opens a new file descriptor from /proc/<self>/fd when
checking for an unlinked file with mode=inode. Ensure that it is
always closed even if the same file test fails.
---
 daemons/dmfilemapd/dmfilemapd.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 6e25c5c..0f3780b 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -600,13 +600,15 @@ check_unlinked:
 	 */
 	if ((fd = open(link_buf, O_RDONLY)) < 0)
 		fm->deleted = 1;
-
-	if ((same = _filemap_monitor_check_same_file(fm->fd, fd)) < 0)
-		return 0;
+	else
+		same = _filemap_monitor_check_same_file(fm->fd, fd);
 
 	if ((fd > 0) && close(fd))
 		log_error("Error closing fd %d", fd);
 
+	if (same < 0)
+		return 0;
+
 	/* Should not happen with normal /proc. */
 	if ((fd > 0) && !same) {
 		log_error("File descriptor mismatch: %d and %s (read from %s) "


