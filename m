From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 15 Apr 2010 16:39:58 -0400
Subject: [PATCH] Add creation of dev/mapper/control to nightly tests.
Message-ID: <1271363998-4897-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This works around a problem with using the /tmp directory for
the dev/mapper/control node.  The failure I saw was this.
When LVM_TEST_DIR was rooted at /tmp/..., the first dmsetup
command would fail with this error:
/tmp/LVMTEST26998.J29FayOVWy/dev/mapper/control: matchpathcon 0020000 failed:

The second dmsetup command would always succeed though.  Also,
when LVM_TEST_DIR was rooted at /root/..., this failure would not
occur.

I stepped through this in gdb and found that mknod was indeed
creating the control node correctly, however, matchpathcon
would fail.  The reason it did not fail the second or subsequent
iterations of dmsetup is that the control node was already there,
and dmsetup does not try to set the selinux security context
in that case.  One clue may be in the fact that it seems the
default security context for files in /tmp/... is <<none>>:
 matchpathcon /root/LVMTEST26998.J29FayOVWy/dev/mapper/control
/root/LVMTEST26998.J29FayOVWy/dev/mapper/control        system_u:object_r:admin_home_t:s0
 matchpathcon /tmp/LVMTEST26998.J29FayOVWy/dev/mapper/control
/tmp/LVMTEST26998.J29FayOVWy/dev/mapper/control <<none>>
 matchpathcon /tmp/LVMTEST26998.J29FayOVWy/dev/mapper/control
/tmp/LVMTEST26998.J29FayOVWy/dev/mapper/control <<none>>
 matchpathcon /dev/mapper/control
/dev/mapper/control     system_u:object_r:lvm_control_t:s0

I would imagine this is why the matchpathcon() call fails.
There may be a better fix for this but at this point for the
nightly tests we can create the 'control' node explicitly.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/test-utils.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/test-utils.sh b/test/test-utils.sh
index c2755c6..92b5047 100644
--- a/test/test-utils.sh
+++ b/test/test-utils.sh
@@ -83,6 +83,8 @@ prepare_testroot() {
 	export LVM_SYSTEM_DIR=$TESTDIR/etc
 	export DM_DEV_DIR=$TESTDIR/dev
 	mkdir $LVM_SYSTEM_DIR $DM_DEV_DIR $DM_DEV_DIR/mapper $TESTDIR/lib
+	minor=`cat /proc/misc | grep device-mapper | awk '{print $1}'`
+	mknod $DM_DEV_DIR/mapper/control c 10 $minor
 
 	cd $TESTDIR
 
-- 
1.6.2.5


