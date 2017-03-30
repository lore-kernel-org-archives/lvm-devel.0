From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:04:04 -0400
Subject: master - dmfilemapd: cast sysconf() return value to int
Message-ID: <201703300904.v2U944I1019926@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bfc880994c80a798f28d51558ee120f70d65dd0f
Commit:        bfc880994c80a798f28d51558ee120f70d65dd0f
Parent:        76b6cbea60b6af6a89d3fc40486486c97df28fcc
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 20:28:43 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 09:57:58 2017 +0100

dmfilemapd: cast sysconf() return value to int

---
 daemons/dmfilemapd/dmfilemapd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 2c80d42..3e691e8 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -660,7 +660,7 @@ static int _daemonise(struct filemap_monitor *fm)
 		}
 	}
 
-	for (fd = sysconf(_SC_OPEN_MAX) - 1; fd > STDERR_FILENO; fd--) {
+	for (fd = (int) sysconf(_SC_OPEN_MAX) - 1; fd > STDERR_FILENO; fd--) {
 		if (fd == fm->fd)
 			continue;
 		close(fd);


