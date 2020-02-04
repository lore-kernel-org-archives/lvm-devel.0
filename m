From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:22:32 -0500
Subject: master - bcache: fix memleak on error path
Message-ID: <37020.120020411222900355@us-mta-428.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c5e5ae4c95e5d02bfa5d018364954281053a9440
Commit:        c5e5ae4c95e5d02bfa5d018364954281053a9440
Parent:        1bde35e596536abc176cb70506353476cd1705b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 29 17:31:17 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

bcache: fix memleak on error path

clang: free io on error path.
---
 lib/device/bcache.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 04d49f1..a7d8055 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -515,6 +515,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 					  (unsigned long long)limit_nbytes,
 					  (unsigned long long)extra_nbytes,
 					  (unsigned long long)_last_byte_sector_size);
+				free(io);
 				return false;
 			}
 		}



