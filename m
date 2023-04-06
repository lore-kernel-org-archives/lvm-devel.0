From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  6 Apr 2023 11:47:41 +0000 (GMT)
Subject: main - WHATS_NEW: update
Message-ID: <20230406114741.04FCA3858433@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b1789b84c39a10241f3e09a4bad16e482db784e4
Commit:        b1789b84c39a10241f3e09a4bad16e482db784e4
Parent:        e59e7aa0ab9dd2d45a1cac46620ffb8d1d2e765c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 6 13:45:42 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 6 13:45:42 2023 +0200

WHATS_NEW: update

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6f801828f..2bff3445d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 version 2.03.21 - 
 =================================
+  Fix activation of vdo-pool for with 0 length headers (converted pools).
+  Avoid printing internal init messages when creation integration devices.
 
 version 2.03.20 - 21st March 2023
 =================================

