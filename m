From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Jan 2020 11:43:41 -0500
Subject: master - WHATS_NEW: update
Message-ID: <33756.120011311433600147@us-mta-304.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=151bf52649ba7a5a6731693e5af8560f6cf1742a
Commit:        151bf52649ba7a5a6731693e5af8560f6cf1742a
Parent:        30f4d0fcd497338be5eb994a9b5b1ccee993f62c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 13 17:37:29 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 13 17:42:53 2020 +0100

WHATS_NEW: update

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index b3c6102..b7aa4e9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.03.08 - 
 ====================================
+  Avoid running cache input arg validation when creating vdo pool.
+  Prevent raid reshaping of stacked volumes.
   Added VDO lvmdbusd methods for enable/disable compression & dedupe.
   Added VDO lvmdbusd method for converting LV to VDO pool.
 



