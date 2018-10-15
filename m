From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:54:55 -0400
Subject: master - cov: fix memleak on bcache io error path
Message-ID: <201810151554.w9FFst3e020510@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b85ecb85b2875bd6743a97147355218879aef3a
Commit:        9b85ecb85b2875bd6743a97147355218879aef3a
Parent:        3222924c3dd595f6d185b180341acfa46954307a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:29:52 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: fix memleak on bcache io error path

Drop allocated IO.

merge free bache
---
 lib/device/bcache.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 5e795c5..43ca63e 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -329,6 +329,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 	r = lseek(fd, where, SEEK_SET);
 	if (r < 0) {
         	log_warn("unable to seek to position %llu", (unsigned long long) where);
+		free(io);
         	return false;
 	}
 
@@ -343,6 +344,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 
         	if (r < 0) {
                 	log_warn("io failed %d", r);
+			free(io);
                 	return false;
         	}
 
@@ -351,6 +353,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 
 	if (len) {
         	log_warn("short io %u bytes remaining", (unsigned) len);
+		free(io);
         	return false;
 	}
 


