From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 21 Jun 2018 04:25:47 -0400
Subject: 2018-06-01-stable - bcache: fix memory leaks
Message-ID: <201806210825.w5L8Pl7A022844@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=acb784e2a87f1a5b57e75c5b92b833306feca9af
Commit:        acb784e2a87f1a5b57e75c5b92b833306feca9af
Parent:        8a0af1bec882de66677e1a0cdceff841c39f92b0
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jun 21 10:22:35 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jun 21 10:22:35 2018 +0200

bcache: fix memory leaks

---
 lib/device/bcache.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 291184d..3b78047 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -319,6 +319,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 	r = lseek(fd, where, SEEK_SET);
 	if (r < 0) {
         	log_warn("unable to seek to position %llu", (unsigned long long) where);
+        	free(io);
         	return false;
 	}
 
@@ -333,6 +334,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 
         	if (r < 0) {
                 	log_warn("io failed %d", r);
+                	free(io);
                 	return false;
         	}
 
@@ -341,6 +343,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 
 	if (len) {
         	log_warn("short io %u bytes remaining", (unsigned) len);
+        	free(io);
         	return false;
 	}
 


