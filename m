From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 May 2018 11:50:00 -0400
Subject: master - WHATS_NEW: updates
Message-ID: <201805151550.w4FFo0sG008397@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1abcee1424022b308fa265037af5826ae2af82d
Commit:        c1abcee1424022b308fa265037af5826ae2af82d
Parent:        889558fedb0f31d754ce146ac0858db1d5613543
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 15 10:49:06 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 15 10:49:06 2018 -0500

WHATS_NEW: updates

---
 WHATS_NEW |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5b1494b..84805a9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.02.178 - 
 =====================================
+  Remove lvm1 and pool format handling and add filter to ignore them.
+  Move some filter checks to after disks are read.
+  Rework disk scanning and when it is used.
+  Add new io layer and shift code to using it.
   lvconvert: don't return success on degraded -m raid1 conversion
   --enable-testing switch for ./configure has been removed.
   --with-snapshots switch for ./configure has been removed.


