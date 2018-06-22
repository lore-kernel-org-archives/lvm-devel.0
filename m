From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 09:08:18 -0400
Subject: 2018-06-01-stable - fsadm: missing -l description
Message-ID: <201806221308.w5MD8Isq019699@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e0c94d883a3ca033df562d63a1074b4be97d98ef
Commit:        e0c94d883a3ca033df562d63a1074b4be97d98ef
Parent:        39e3b5d8ac58dda328ddbc97daafb9800d7e954b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 22 15:00:52 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 15:00:52 2018 +0200

fsadm: missing -l description

---
 WHATS_NEW        |    1 +
 man/fsadm.8_main |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6560e57..36523f5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.180 - 
 =================================
+  Add missing -l description in fsadm man page.
   Cache can uses metadata format 2 with cleaner policy.
   Avoid showing internal error in lvs output or pvmoved LVs.
   Fix check if resized PV can also fit metadata area.
diff --git a/man/fsadm.8_main b/man/fsadm.8_main
index 799cb25..92ee902 100644
--- a/man/fsadm.8_main
+++ b/man/fsadm.8_main
@@ -40,6 +40,11 @@ filesystem.
 Unmount ext2/ext3/ext4 filesystem before doing resize.
 .
 .HP
+.BR -l | --lvresize
+.br
+Resize given device if it is LVM device.
+.
+.HP
 .BR -f | --force
 .br
 Bypass some sanity checks.


