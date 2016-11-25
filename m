From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 25 Nov 2016 10:32:01 +0000 (UTC)
Subject: master - scripts: fix comment about blk-availability init script
Message-ID: <20161125103201.543EE60772@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ad66b4e7bf1c88bd57b6d97f9feb07b99ae3e19
Commit:        2ad66b4e7bf1c88bd57b6d97f9feb07b99ae3e19
Parent:        064e24bc1e9f5b84a5987febaf0d11e5aeae39e2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Nov 25 11:30:48 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Nov 25 11:30:55 2016 +0100

scripts: fix comment about blk-availability init script

The original comment got there as copy-paste error and it wasn't edited
properly for blk-availability.
---
 scripts/blk_availability_init_red_hat.in |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/scripts/blk_availability_init_red_hat.in b/scripts/blk_availability_init_red_hat.in
index a84ffe7..657616e 100644
--- a/scripts/blk_availability_init_red_hat.in
+++ b/scripts/blk_availability_init_red_hat.in
@@ -10,10 +10,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 #
-# This file is part of LVM2.
-# It is required for the proper handling of failures of LVM2 mirror
-# devices that were created using the -m option of lvcreate.
-#
+# This script is responsible for executing blkdeactivate at shutdown
+# to properly unmount filesystems and deactivate device stacks containing
+# device-mapper devices (including plain device-mapper devices, LVM2 and
+# multipath devices) and MD devices.
 #
 # chkconfig: 12345 25 75
 # description: Controls availability of block devices


