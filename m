From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Feb 2019 17:47:08 -0500
Subject: stable-2.02 - WHATS_NEW: scan_lvs
Message-ID: <201902202247.x1KMl8I9005067@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=083f162e8e01eca1a6c66b4d9bfeede05ed6feab
Commit:        083f162e8e01eca1a6c66b4d9bfeede05ed6feab
Parent:        7f56908c2beb6161256af4ccdbeaf86309a9b6cf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 20 14:33:09 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 20 14:33:09 2019 -0600

WHATS_NEW: scan_lvs

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4d1ece4..cbb5505 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.184 - 
 =====================================
+  Change scan_lvs default to 0 so LVs are not scanned for PVs.
+  Add scan_lvs config setting to control if lvm scans LVs for PVs.
   Fix missing proper initialization of pv_list struct when adding pv.
 
 Version 2.02.183 - 07th December 2018


