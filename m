From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:04:02 -0400
Subject: master - dmfilemapd: fix len type in _filemap_monitor_check_file_unlinked()
Message-ID: <201703300904.v2U9422i019916@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76b6cbea60b6af6a89d3fc40486486c97df28fcc
Commit:        76b6cbea60b6af6a89d3fc40486486c97df28fcc
Parent:        660bd4fe3e86cc68d269ad707919f040b163f164
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 20:26:39 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 09:57:58 2017 +0100

dmfilemapd: fix len type in _filemap_monitor_check_file_unlinked()

Make 'len' a size_t to match the return type of readlink(2).
---
 daemons/dmfilemapd/dmfilemapd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 225335c..2c80d42 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -559,7 +559,8 @@ static int _filemap_monitor_check_file_unlinked(struct filemap_monitor *fm)
 {
 	char path_buf[PATH_MAX];
 	char link_buf[PATH_MAX];
-	int same, fd, len;
+	int same, fd;
+	ssize_t len;
 
 	fm->deleted = 0;
 


