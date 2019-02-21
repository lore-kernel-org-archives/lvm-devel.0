From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Feb 2019 16:31:56 -0500
Subject: master - WHATS_NEW: concurrent pvscan autoactivation
Message-ID: <201902212131.x1LLVuHp001243@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eff33684f774bb732e66898a65c52163d0987b70
Commit:        eff33684f774bb732e66898a65c52163d0987b70
Parent:        74a388cca15baa4149a24e37bccb421c53f726e5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 21 15:31:23 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 21 15:31:23 2019 -0600

WHATS_NEW: concurrent pvscan autoactivation

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8088060..b1b19d1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Fix pvscan autoactivation for concurrent pvscans.
   Change scan_lvs default to 0 so LVs are not scanned for PVs.
   Thin-pool selects power-of-2 chunk size by default.
   Cache selects power-of-2 chunk size by default.


