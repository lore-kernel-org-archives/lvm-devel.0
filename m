From: David Teigland <teigland@sourceware.org>
Date: Mon, 8 Apr 2019 11:57:09 -0400
Subject: master - WHATS_NEW: add several recent changes
Message-ID: <201904081557.x38Fv9ng025928@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=344a9e9afd9f9038f53887e55e721033d1dc3b65
Commit:        344a9e9afd9f9038f53887e55e721033d1dc3b65
Parent:        7836e7aa1c17216ed368fda89cfc805a07efda81
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 8 10:56:43 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 8 10:56:43 2019 -0500

WHATS_NEW: add several recent changes

---
 WHATS_NEW |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 81c3d71..728019e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,11 @@
 Version 2.03.02 - 
 ===================================
+  Skip autoactivation for a PV when PV size does not match device size.
+  Remove first-pvscan-initialization which should no longer be needed.
+  Add remote refresh through lvmlockd/dlm for shared LVs after lvextend.
+  Ignore foreign and shared PVs for pvscan online files.
+  Add config setting to control fields in debug file and verbose output.
+  Add command[pid] and timestamp to debug file and verbose output.
   Fix missing growth of _pmsmare volume when extending _tmeta volume.
   Automatically grow thin metadata, when thin data gets too big.
   Add synchronization with udev before removing cached devices.


