From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 26 Oct 2017 12:18:40 -0400
Subject: master - WHATS_NEW: ignore stripes/stripesize on RAID takover
Message-ID: <201710261618.v9QGIeWO016023@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdcc709ed0e5051f471ee64ac51f6c8e2ed941fc
Commit:        fdcc709ed0e5051f471ee64ac51f6c8e2ed941fc
Parent:        adb80816fbd95215ffc18fdfe5901abed25787c2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Oct 26 18:18:24 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Oct 26 18:18:24 2017 +0200

WHATS_NEW: ignore stripes/stripesize on RAID takover

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 55e06f6..fbf8732 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Ignore --stripes/--stripesize on RAID takeover
   Improve used paths for generated systemd units and init shells.
   Disallow creation of snapshot of mirror/raid subLV (was never supported).
   Fix regression in more advanced vgname extraction in lvconvert (2.02.169).


