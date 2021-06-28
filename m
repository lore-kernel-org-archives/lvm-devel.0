From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jun 2021 18:42:31 +0000 (GMT)
Subject: master - WHATS_NEW: update
Message-ID: <20210628184231.226FF3988429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39f497b9d8d35c77716014a3ba7074a2fc8955ac
Commit:        39f497b9d8d35c77716014a3ba7074a2fc8955ac
Parent:        580e64e93ba469b64cf11e400c4cb2f759eaf579
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 28 20:38:54 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 28 20:41:07 2021 +0200

WHATS_NEW: update

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2c4704310..8f6dad27a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.03.13 - 
 ===============================
+  Support configurable allocation/vdo_pool_header_size.
+  Fix handling of lvconvert --type vdo-pool --virtualsize.
   Simplified handling of archive() and backup() internal calls.
   Fix load of kvdo target when it is not present in memory (2.03.12).
 


