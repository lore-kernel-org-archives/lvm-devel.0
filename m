From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 31 Jul 2018 12:46:51 -0400
Subject: 2018-06-01-stable - WHATS_NEW
Message-ID: <201807311646.w6VGkpET005236@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad10d426711b06dab4e5fda3538fb3a7a1ade30d
Commit:        ad10d426711b06dab4e5fda3538fb3a7a1ade30d
Parent:        f7645995da292678cf49528ca618ecc8cd3f31b4
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 31 17:02:47 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 31 17:41:31 2018 +0200

WHATS_NEW

---
 WHATS_NEW |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3b15325..546d3e6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,10 @@
 Version 2.02.181 - 
 =================================
-  lvconvert: reject conversions on raid1 LVs with split tracked SubLVs
-  lvconvert: reject conversions on raid1 split tracked SubLVs
+  Reject conversions on raid1 LVs with split tracked SubLVs.
+  Reject conversions on raid1 split tracked SubLVs.
+  Fix dmstats list failing when no regions exist.
+  Reject conversions of LVs under snapshot.
+  Limit suggested options on incorrect option for lvconvert subcommand.
 
 Version 2.02.180 - 19th July 2018
 =================================


