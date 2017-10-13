From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 13 Oct 2017 07:11:43 -0400
Subject: master - Update WHATS_NEW
Message-ID: <201710131111.v9DBBhQw015027@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e14c0cabd961432d25d36ae11a26c47a7962ac24
Commit:        e14c0cabd961432d25d36ae11a26c47a7962ac24
Parent:        cf13a30eaaf9c9d013f03bfcba1c1bc4973ad5d5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Oct 13 13:11:01 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Oct 13 13:11:01 2017 +0200

Update WHATS_NEW

---
 WHATS_NEW |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e392722..005a1bf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,9 +1,11 @@
 Version 2.02.176 -
 ===================================
-  Improve selection of resource name for activation lock.
-  Avoid cutting 1st. character of resource name for activation lock.
+  Allow lvcreate --type mirror to work with 100%FREE.
+  Improve selection of resource name for complex volume activation lock.
+  Avoid cutting first character of resource name for activation lock.
   Support for encrypted devices in fsadm.
   Improve thin pool overprovisioning and repair warning messages.
+  Fix incorrect adjustment of region size on striped RaidLVs.
 
 Version 2.02.175 - 6th October 2017
 ===================================


