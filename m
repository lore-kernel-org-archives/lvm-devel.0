From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:57 -0500
Subject: master - bcache: fix memory leak on error path
Message-ID: <201812212046.wBLKkvAG021434@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82f66834ef779414cd2c5cb258d9a45580c07009
Commit:        82f66834ef779414cd2c5cb258d9a45580c07009
Parent:        a13fa75d8e89d2eb88a707e35ba472b7d6189d07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 21:01:18 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:45:03 2018 +0100

bcache: fix memory leak on error path

Coverity noticed missing free of io struct on error path.
---
 WHATS_NEW           |    1 +
 lib/device/bcache.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1bebff6..3fe1f3e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Fix memleak on bcache error path code.
   Fix missing unlock on lvm2 dmeventd plugin error path initialization.
   Improve Makefile dependency tracking.
   Move VDO support towards V2 target (6.2) support.
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index d646d2b..7b09353 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -409,6 +409,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 				  (unsigned long long)offset,
 				  (unsigned long long)nbytes,
 				  (unsigned long long)_last_byte_offset);
+			free(io);
 			return false;
 		}
 


