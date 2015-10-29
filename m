From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 Oct 2015 15:50:22 +0000 (UTC)
Subject: master - WHATS_NEW: recent commits
Message-ID: <20151029155022.34C626100F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=406d8ff3323dde6860d88b603701aa4dace47af0
Commit:        406d8ff3323dde6860d88b603701aa4dace47af0
Parent:        00348c0a630a7e5578edf48052ec695b15de752f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 29 16:50:09 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 29 16:50:09 2015 +0100

WHATS_NEW: recent commits

---
 WHATS_NEW |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 03c70d6..00e807e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.133 - 
 ======================================
-  Check metadata area size is at least minimum size of 8 * memory page size.
+  Check newly created VG's metadata do not overlap in metadata ring buffer.
+  Check metadata area size is at least the minimum size defined for the format.
   Thin pool targets uses low_water_mark from profile.
   Dropping 'yet' from error of unsupported thick snapshot of snapshots.
   Do not support unpartitioned DASD devices with CDL formatted with pvcreate.


