From: Marian Csontos <mcsontos@sourceware.org>
Date: Sun,  9 Aug 2020 15:01:24 +0000 (GMT)
Subject: master - WHATS_NEW
Message-ID: <20200809150124.15E343857C4A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1d136fea3d127d8ecd5c30208c919490a58ff59
Commit:        c1d136fea3d127d8ecd5c30208c919490a58ff59
Parent:        9f8c331760c08d4da0bb03c4fce4946b0236c0ac
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Sun Aug 9 16:15:13 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Sun Aug 9 16:17:15 2020 +0200

WHATS_NEW

---
 WHATS_NEW | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 87779c3e7..ac99e970d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,9 @@
 Version 2.03.10 - 
-=================================
-  Add writecache support to lvmdbusd.
+==================================
+  Add writecache and integrity support to lvmdbusd.
+  Generate unique cachevol name when default required from lvcreate.
+  Converting RAID1 volume to one with same number of legs now succeeds with a
+  warning.
   Fix conversion to raid from striped lagging type.
   Fix conversion to 'mirrored' mirror log with larger regionsize.
   Zero pool metadata on allocation (disable with allocation/zero_metadata=0).


