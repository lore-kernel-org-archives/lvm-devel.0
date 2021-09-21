From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:51:09 +0000 (GMT)
Subject: main - cov: ignore leak of fd descriptor
Message-ID: <20210921195109.8E4393858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0d40109a67a99bf568c168a31f37955a07d7da4
Commit:        b0d40109a67a99bf568c168a31f37955a07d7da4
Parent:        e6d35874827f14d392c4ba4f8608eb0444230c7b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 20:20:53 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

cov: ignore leak of fd descriptor

There is no 'fd' leak.
---
 libdm/dm-tools/dmfilemapd.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/libdm/dm-tools/dmfilemapd.c b/libdm/dm-tools/dmfilemapd.c
index d7ca71d7e..d547e59d5 100644
--- a/libdm/dm-tools/dmfilemapd.c
+++ b/libdm/dm-tools/dmfilemapd.c
@@ -671,12 +671,11 @@ static int _daemonise(struct filemap_monitor *fm)
 			(void) close(fd);
 	}
 	/* TODO: Use libdaemon/server/daemon-server.c _daemonise() */
-	for (ffd = (int) sysconf(_SC_OPEN_MAX) - 1; ffd > STDERR_FILENO; --ffd) {
-		if (ffd == fm->fd)
-			continue;
-		(void) close(ffd);
-	}
+	for (ffd = (int) sysconf(_SC_OPEN_MAX) - 1; ffd > STDERR_FILENO; --ffd)
+		if (ffd != fm->fd)
+			(void) close(ffd);
 
+	/* coverity[leaked_handle] no leak */
 	return 1;
 }
 


