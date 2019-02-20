From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Feb 2019 15:05:26 -0500
Subject: master - WHATS_NEW: scan_lvs default change
Message-ID: <201902202005.x1KK5QO1011337@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=71a302effe82f1cc89f0b26b358493cfaaed7de7
Commit:        71a302effe82f1cc89f0b26b358493cfaaed7de7
Parent:        fedeab28c3096b5afb3fdc397fe8d18455247756
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 20 14:04:49 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 20 14:04:49 2019 -0600

WHATS_NEW: scan_lvs default change

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 29ade99..8088060 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Change scan_lvs default to 0 so LVs are not scanned for PVs.
   Thin-pool selects power-of-2 chunk size by default.
   Cache selects power-of-2 chunk size by default.
   Support reszing for VDOPoolLV and VDOLV.


