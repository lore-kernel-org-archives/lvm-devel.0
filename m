From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Sep 2013 11:01:33 +0000 (UTC)
Subject: master - WHATS_NEW: for commit 8d1d8350 and 72a9d4f
Message-ID: <20130911110133.6805D60F66@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe227d14a5947357a784661e32e74690b9eb226f
Commit:        fe227d14a5947357a784661e32e74690b9eb226f
Parent:        72a9d4f879751d58e531efbffaef1f7d325092c7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 11 12:58:43 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 11 13:01:01 2013 +0200

WHATS_NEW: for commit 8d1d8350 and 72a9d4f

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b14daf5..61a66a2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.101 - 
 ===================================
+  Direct udev to use 3min timeout for LVM devices. Recent udev has default 30s.
+  Fix MD/loop udev handling to fire autoactivation after setup or coldplug only.
   Make RAID capable of single-machine exclusive operations in a cluster.
   Drop calculation of read ahead for deactivated volume.
   Check for exactly one lv segment in validation of thin pools and volumes.


