From: David Teigland <teigland@sourceware.org>
Date: Mon, 4 Mar 2019 13:23:36 -0500
Subject: master - WHATS_NEW: io_memory_size
Message-ID: <201903041823.x24INaoL014624@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07483cc165e210a23627b4b6d5c89f9008c9e950
Commit:        07483cc165e210a23627b4b6d5c89f9008c9e950
Parent:        7edbf8a441fab4518959523e3e726bcd66b2c6a8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 4 12:22:49 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 4 12:22:49 2019 -0600

WHATS_NEW: io_memory_size

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b1b19d1..61d347a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.03.02 - 
 ===================================
+  Change default io_memory_size from 4 to 8 MiB.
+  Add config setting io_memory_size to set bcache size.
   Fix pvscan autoactivation for concurrent pvscans.
   Change scan_lvs default to 0 so LVs are not scanned for PVs.
   Thin-pool selects power-of-2 chunk size by default.


