From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Apr 2016 10:58:18 +0000 (UTC)
Subject: master - udev: rules: add comments explaining subsystem-specific rules
Message-ID: <20160426105818.4865C60E4C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ecae76c713bd4fa6c9d8f2a2c990625e4f38b504
Commit:        ecae76c713bd4fa6c9d8f2a2c990625e4f38b504
Parent:        2bb33aaf556134b0217b822755383245ac678527
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 26 12:51:06 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 26 12:57:37 2016 +0200

udev: rules: add comments explaining subsystem-specific rules

---
 udev/10-dm.rules.in |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 8d7a8ca..b4fa52a 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -13,6 +13,20 @@
 #   DM_UUID - UUID set for DM device (blank if not specified)
 #   DM_SUSPENDED - suspended state of DM device (0 or 1)
 #   DM_UDEV_RULES_VSN - DM udev rules version
+#
+# These rules cover only basic device-mapper functionality in udev.
+#
+# Various DM subsystems may contain further subsystem-specific rules
+# in 11-dm-<subsystem_name>.rules which should be installed together
+# with the DM subsystem and which extend these basic rules.
+# For example:
+#   11-dm-lvm.rules for LVM subsystem
+#   11-dm-mpath.rules for multipath subsystem (since version 0.6.0, recommended!)
+#
+# Even more specific rules may be required by subsystems so always
+# check subsystem's upstream repository for recent set of rules.
+# Also, keep in mind that recent rules may also require recent
+# subsystem-specific binaries.
 
 KERNEL=="device-mapper", NAME="(DM_DIR)/control"
 


