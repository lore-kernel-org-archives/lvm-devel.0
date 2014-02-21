From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 21 Feb 2014 10:37:08 +0000 (UTC)
Subject: master - WHATS_NEW: for commit b391ae88e5ed3720a8b5a87312e0cd907a94fcc2
Message-ID: <20140221103708.D8EC961168@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84d02542bd1e52e2f8721a56b0d98d23c478205e
Commit:        84d02542bd1e52e2f8721a56b0d98d23c478205e
Parent:        bbe4aca7c42ee3b1e620fb673a739b4b0f777144
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 21 11:36:55 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 21 11:36:55 2014 +0100

WHATS_NEW: for commit b391ae88e5ed3720a8b5a87312e0cd907a94fcc2

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c081898..23f7424 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Avoid a PV label scan while in a critical section.
   Remove (always 0) skip argument from lv_activation_skip().
   Create /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> symlink for each PV via udev.
   lvcreate computes RAID4/5/6 stripes if not given from # of allocatable PVs.


