From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 14:48:38 +0000 (UTC)
Subject: master - tests: skips on unsupported systems
Message-ID: <20140521144838.21BE960926@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8db67d2aff7757d022f7d339451aeb93b0374311
Commit:        8db67d2aff7757d022f7d339451aeb93b0374311
Parent:        092659644a6da359272b852d6be058a5fc26bff4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 16:48:06 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 16:48:06 2014 +0200

tests: skips on unsupported systems

---
 test/shell/profiles-thin.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 1056528..25c12eb 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -17,10 +17,13 @@
 
 DEV_SIZE=32
 
+# check we have thinp support compiled in
+aux have_thin 1 0 0 || skip
+
 aux prepare_profiles "thin-performance"
 
 # Create scsi debug dev with sector size of 4096B and 1MiB optimal_io_size
-aux prepare_scsi_debug_dev $DEV_SIZE sector_size=4096 opt_blks=256
+aux prepare_scsi_debug_dev $DEV_SIZE sector_size=4096 opt_blks=256 || skip
 aux prepare_pvs 1 $DEV_SIZE
 vgcreate $vg "$dev1"
 


