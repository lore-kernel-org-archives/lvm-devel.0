From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 16 Jan 2013 10:22:26 +0000 (UTC)
Subject: master - Update WHATS_NEW.
Message-ID: <20130116102226.C634D167A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=142c4bf9f04a46daf1c3d94581b43ec7c481ba59
Commit:        142c4bf9f04a46daf1c3d94581b43ec7c481ba59
Parent:        1e4a9534f4c0a04300f07bdbcfb62ba18bc82523
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 16 11:22:08 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jan 16 11:22:08 2013 +0100

Update WHATS_NEW.

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c801f44..987cefa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix a crash-inducing race condition in lvmetad.
   Add log/debug_classes to lvm.conf to control debug log messages.
   Synchronize with udev in pvscan --cache and fix dangling udev_sync cookies.
   Fix autoactivation to not autoactivate VG/LV on each change of the PVs used.


