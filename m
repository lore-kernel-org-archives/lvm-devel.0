From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 19:56:15 +0000 (GMT)
Subject: main - WHATS_NEW: update
Message-ID: <20230210195615.7C2663858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1bfa400a18c0223dcc60379dcec8b05b2ef6d5c
Commit:        d1bfa400a18c0223dcc60379dcec8b05b2ef6d5c
Parent:        21edfc4a5ea11d888f506b41d36a0ec983dc63c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 20:51:46 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 20:54:05 2023 +0100

WHATS_NEW: update

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1a0812df8..248e30f5c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 version 2.03.19 - 
 ====================================
+  Configure supports --with-systemd-run executed from udev rules.
+  Enhancement for build with MuslC systemd and non-bash system shells (dash).
   Do not reset SYSTEMD_READY variable in udev for PVs on MD and loop devices.
   Ensure udev is processing origin LV before its thick snapshots LVs.
   Fix and improve runtime memory size detection for VDO volumes.

