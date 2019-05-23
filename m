From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 May 2019 12:50:48 -0400
Subject: master - WHATS_NEW: pvck --dump
Message-ID: <201905231650.x4NGomNO026234@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef2d61fea81dbae3d1a32d20ee22d2afae7701af
Commit:        ef2d61fea81dbae3d1a32d20ee22d2afae7701af
Parent:        52586b1039a0c1d273676416ba074cadde308bc4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 23 11:50:16 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 23 11:50:16 2019 -0500

WHATS_NEW: pvck --dump

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6ab973d..fd27c33 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Add pvck --dump option to extract metadata.
   Fix signal delivery checking race in libdaemon (lvmetad).
   Add missing Before=shutdown.target to LVM2 services to fix shutdown ordering.
   Skip autoactivation for a PV when PV size does not match device size.


