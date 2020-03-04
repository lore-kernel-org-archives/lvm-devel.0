From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 4 Mar 2020 07:25:49 -0500
Subject: stable-2.02 - bcache: Fix memory leak in error path
Message-ID: <202003041225.024CPnW5005019@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=deaf304ee6d88cd47632a345b92b3949cd06d752
Commit:        deaf304ee6d88cd47632a345b92b3949cd06d752
Parent:        44c460954be5c63cf5338bd9151344fe2626565f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 4 13:22:10 2020 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 4 13:22:10 2020 +0100

bcache: Fix memory leak in error path

---
 lib/device/bcache.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 77d1543c0..a74b6b315 100644
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



