From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 15:26:34 +0000 (UTC)
Subject: master - tests: check thin is not flushed for status
Message-ID: <20160527152634.5F93F61C43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d4d0ff606a78909041c0b734a3ceacc94a47fa0
Commit:        7d4d0ff606a78909041c0b734a3ceacc94a47fa0
Parent:        88eeb004e9d34635221d45619723518a71ac2ccc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 27 17:24:18 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 17:25:52 2016 +0200

tests: check thin is not flushed for status

We finally approach a moment where we generally avoid
flushing thin-pool with every lvs command...
---
 test/shell/thin-flags.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 966752a..3fcafb2 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -52,6 +52,10 @@ lvcreate -T -L1M --errorwhenfull y $vg/pool
 lvcreate -V2 -n $lv2 $vg/pool
 
 aux error_dev  "$dev2" 2054:2
+# Check our 'lvs' is not flushing pool - should be still OK
+check lv_attr_bit health $vg/pool "-"
+# Enforce flush on thin pool device to notice error device.
+dmsetup status $vg-pool-tpool
 check lv_attr_bit health $vg/pool "F"
 check lv_attr_bit health $vg/$lv2 "F"
 aux enable_dev "$dev2"


