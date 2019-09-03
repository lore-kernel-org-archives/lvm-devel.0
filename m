From: David Teigland <teigland@sourceware.org>
Date: Tue, 3 Sep 2019 13:03:54 -0400
Subject: master - bcache: change log level for prefetch message
Message-ID: <201909031703.x83H3spe019618@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fcbffbdbc0a29287c65bfc378eb8aa99fd6490c1
Commit:        fcbffbdbc0a29287c65bfc378eb8aa99fd6490c1
Parent:        25b58310e3d606a85abc9bd50991ccb7ddcbfe25
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 3 12:02:09 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 3 12:02:09 2019 -0500

bcache: change log level for prefetch message

The "new new blocks" message was printed as an error
but it's not an error condition.
---
 lib/device/bcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 04fbf35..d100419 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -957,7 +957,7 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address i, b
 					_writeback(cache, 16);  // FIXME: magic number
 				_wait_io(cache);
 			} else {
-				log_error("bcache no new blocks for fd %d index %u",
+				log_debug("bcache no new blocks for fd %d index %u",
 					  fd, (uint32_t) i);
 				return NULL;
 			}


