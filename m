From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 12 Sep 2013 12:17:26 +0000 (UTC)
Subject: master - WHATS_NEW: some missing lines
Message-ID: <20130912121726.2931E60F02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2268aeb92779580d3da4c5c400a1c353f955571
Commit:        e2268aeb92779580d3da4c5c400a1c353f955571
Parent:        6940e24aeeff3d6c5c8da259b74afd908b4716f2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 12 14:16:54 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 12 14:16:54 2013 +0200

WHATS_NEW: some missing lines

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c61070e..a46b0b4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.101 - 
 ===================================
+  Add man page entries for lvmdump's -u and -l options.
+  Fix lvm2app segfault while using lvm_list_pvs_free fn if there are no PVs.
   Improve of clvmd singlenode locking simulation.
   Disallow thinpools on mirror logical volumes.
   Direct udev to use 3min timeout for LVM devices. Recent udev has default 30s.


