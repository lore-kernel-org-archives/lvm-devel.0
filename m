From: David Teigland <teigland@sourceware.org>
Date: Tue, 30 Jul 2019 17:15:31 -0400
Subject: stable-2.02 - WHATS_NEW: fix large physical block size
Message-ID: <201907302115.x6ULFVMm018148@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b387d026bd065b99f894a5c7b67d1f0441b583f3
Commit:        b387d026bd065b99f894a5c7b67d1f0441b583f3
Parent:        a178ad0858a9fa3fbef97b3fa5148ab432b61422
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 30 16:14:46 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 30 16:14:46 2019 -0500

WHATS_NEW: fix large physical block size

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d3da403..d30e5cd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.186 - 
 ================================
+  Fix metadata writes from corrupting with large physical block size.
   Report no_discard_passdown for cache LVs with lvs -o+kernel_discards.
   Prevent shared active mirror LVs with lvmlockd.
 


