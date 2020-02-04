From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:22:31 -0500
Subject: master - dmsetup: no memleak on failed realocation
Message-ID: <39162.120020411222201734@us-mta-406.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ac38b576f9f6daedf22a0d8472586bfe7de7c57e
Commit:        ac38b576f9f6daedf22a0d8472586bfe7de7c57e
Parent:        62ad12d0d05d8ffa26df4f1b1b6ef3b2113420b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 29 16:30:16 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

dmsetup: no memleak on failed realocation

clang: keep old buf pointer for release on failing realloc() codepath.
---
 libdm/dm-tools/dmsetup.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 269f86c..d01b8f2 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -1216,7 +1216,7 @@ out:
 
 static char *_slurp_stdin(void)
 {
-	char *buf, *pos;
+	char *newbuf, *buf, *pos;
 	size_t bufsize = DEFAULT_BUF_SIZE;
 	size_t total = 0;
 	ssize_t n = 0;
@@ -1245,10 +1245,12 @@ static char *_slurp_stdin(void)
 		pos += n;
 		if (total == bufsize - 1) {
 			bufsize *= 2;
-			if (!(buf = realloc(buf, bufsize))) {
+			if (!(newbuf = realloc(buf, bufsize))) {
 				log_error("Buffer memory extension to %" PRIsize_t " bytes failed.", bufsize);
+				free(buf);
 				return NULL;
 			}
+			buf = newbuf;
 		}
 	} while (1);
 



