From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 11 May 2016 14:36:37 +0000 (UTC)
Subject: master - test: process-each-duplicate-pvs
Message-ID: <20160511143637.95D1860228@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3d508630d7acdd638afae700973f1d68e43cbcc
Commit:        f3d508630d7acdd638afae700973f1d68e43cbcc
Parent:        5c18b0ce9c5e4f94cce83a98cb2d996875cfa812
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 11 09:35:07 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 11 09:35:42 2016 -0500

test: process-each-duplicate-pvs

skip on RHEL5 where DEV_USED_FOR_LV doesn't work
because it depends on a newer bit of sysfs.
---
 test/shell/process-each-duplicate-pvs.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index 41d844d..9ab98dc 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -15,6 +15,11 @@ SKIP_WITH_CLVMD=1
 
 aux prepare_devs 6 16
 
+# The LV-using-PV tests (DEV_USED_FOR_LV, where a PV is
+# preferred if an active LV is using it) depend on sysfs
+# info that is not available in RHEL5 kernels.
+aux driver_at_least 4 15 || skip
+
 aux lvmconf 'devices/allow_changes_with_duplicate_pvs = 0'
 
 pvcreate "$dev1"


