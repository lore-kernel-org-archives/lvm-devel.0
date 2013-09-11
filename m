From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Sep 2013 11:17:08 +0000 (UTC)
Subject: master - WHATS_NEW: one more for commit 8d1d835
Message-ID: <20130911111708.18C3261157@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f4bc637b4b71ed7a66ea4e7836c51b529bef92a
Commit:        1f4bc637b4b71ed7a66ea4e7836c51b529bef92a
Parent:        fe227d14a5947357a784661e32e74690b9eb226f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 11 13:15:53 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 11 13:16:36 2013 +0200

WHATS_NEW: one more for commit 8d1d835

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 61a66a2..927419a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.101 - 
 ===================================
   Direct udev to use 3min timeout for LVM devices. Recent udev has default 30s.
+  Do not scan multipath or RAID components and avoid incorrect autoactivation.
   Fix MD/loop udev handling to fire autoactivation after setup or coldplug only.
   Make RAID capable of single-machine exclusive operations in a cluster.
   Drop calculation of read ahead for deactivated volume.


