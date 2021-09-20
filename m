From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:13 +0000 (GMT)
Subject: main - cov: capture runtime exception
Message-ID: <20210920133013.40FFF3858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3f946bfce72952bc9e775ec41278dd33afbc9eb1
Commit:        3f946bfce72952bc9e775ec41278dd33afbc9eb1
Parent:        d5c82b0e73421eb57bf36578b39813915af4676b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 10:26:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: capture runtime exception

---
 test/lib/brick-shelltest.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 8637d8a9f..0b1f9dfee 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -536,7 +536,11 @@ struct FileSource : Source {
                 lseek( fd, 0, SEEK_END );
         }
         if ( fd >= 0 )
-            Source::sync( s );
+            try {
+                Source::sync( s );
+            } catch (...) {
+                perror("failed to sync");
+            }
     }
 };
 


