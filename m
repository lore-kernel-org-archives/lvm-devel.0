From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:27 -0400
Subject: master - dmfilemapd: fix off-by-one in fd comparison (coverity)
Message-ID: <201703292016.v2TKGRlb000791@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f66bc3dab07f3394150536819943a5c31ce793bf
Commit:        f66bc3dab07f3394150536819943a5c31ce793bf
Parent:        8658bbe3eed38183554643f93f4c23718fd24827
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 17:25:20 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:34:19 2017 +0100

dmfilemapd: fix off-by-one in fd comparison (coverity)

The function _filemap_monitor_check_file_unlinked() attempts to
test whether a fd value should be closed by comparison to zero:

        if ((fd > 0) && close(fd))
                log_error("Error closing fd %d", fd);

The test should be '>=' since 0 is a valid file descriptor.
---
 daemons/dmfilemapd/dmfilemapd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 0f3780b..2fa51ee 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -603,7 +603,7 @@ check_unlinked:
 	else
 		same = _filemap_monitor_check_same_file(fm->fd, fd);
 
-	if ((fd > 0) && close(fd))
+	if ((fd >= 0) && close(fd))
 		log_error("Error closing fd %d", fd);
 
 	if (same < 0)


