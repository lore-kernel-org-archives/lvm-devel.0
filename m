From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 14 Jun 2013 08:04:47 +0000 (UTC)
Subject: master - man: refine lvm.conf and man page documentation for autoactivation feature
Message-ID: <20130614080447.68E5360BBA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dba53681a5d31c7f9510cf64637e2fbc707fb899
Commit:        dba53681a5d31c7f9510cf64637e2fbc707fb899
Parent:        fa5d4bc7807c8ab84e65304e52532ee05ee4e172
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 14 09:36:56 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 14 10:02:56 2013 +0200

man: refine lvm.conf and man page documentation for autoactivation feature

---
 WHATS_NEW           |    1 +
 doc/example.conf.in |   26 +++++++++++++++++++++++---
 man/lvchange.8.in   |    5 +++--
 man/pvscan.8.in     |    5 +++--
 man/vgchange.8.in   |    5 +++--
 5 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 86b1f03..a061467 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Refine lvm.conf and man page documentation for autoactivation feature.
   Add support for thin volumes in vgsplit.
   Also filter partitions on mpath components if multipath_component_detection=1.
   Add lvresize support for online thin pool metadata volume resize.
diff --git a/doc/example.conf.in b/doc/example.conf.in
index 9670b92..7800d15 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -646,9 +646,29 @@ activation {
     # volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 
     # If auto_activation_volume_list is defined, each LV that is to be
-    # activated with the autoactivation option (--activate ay/-a ay)
-    # is first checked against the list.  If it does not match, the LV
-    # is not activated.  This list is checked as well as volume_list.
+    # activated with the autoactivation option (--activate ay/-a ay) is
+    # first checked against the list. There are two scenarios in which
+    # the autoactivation option is used:
+    #
+    #   - automatic activation of volumes based on incoming PVs. If all the
+    #     PVs making up a VG are present in the system, the autoactivation
+    #     is triggered. This requires lvmetad (global/use_lvmetad=1) and udev
+    #     to be running. In this case, "pvscan --cache -aay" is called
+    #     automatically without any user intervention while processing
+    #     udev events. Please, make sure you define auto_activation_list
+    #     properly so only the volumes you want and expect are autoactivated.
+    #
+    #   - direct activation on command line with the autoactivation option.
+    #     In this case, the user calls "vgchange --activate ay/-a ay" or
+    #     "lvchange --activate ay/-a ay" directly.
+    #
+    # If the VG/LV being processed does not match the list, the VG/LV is not
+    # activated. If auto_activation_volume_list is not set, then all volumes
+    # are activated by default.
+    #
+    # N.B. The "activation/volume_list" is still honoured in all cases so even
+    # if the VG/LV passes the auto_activation_volume_list, it still needs to
+    # pass the volume_list for it to be activated in the end.
     #
     #   "vgname" and "vgname/lvname" are matched exactly.
     #   "@tag" matches any tag set in the LV or VG.
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 2271d4c..d5041f3 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -65,8 +65,9 @@ libdevmapper to activate (\-ay) or deactivate (\-an) the
 logical volumes. If autoactivation option is used (\-aay),
 the logical volume is activated only if it matches an item in
 the activation/auto_activation_volume_list set in lvm.conf.
-Autoactivation is not yet supported for logical volumes that
-are part of partial or clustered volume groups.
+If this list is not set, then all volumes are considered for
+autoactivation. The autoactivation is not yet supported for
+logical volumes that are part of partial or clustered volume groups.
 .IP
 If clustered locking is enabled, -aey will activate exclusively
 on one node and -aly will activate only on the local node.
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index 1be3109..2246744 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -47,8 +47,9 @@ Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
 Together with the information already cached in lvmetad, automatically activate
 any logical volumes that become activatable after the scan done on one or more devices.
 The logical volume to autoactivate is matched against the
-activation/auto_activation_volume_list set in lvm.conf. Autoactivation is not yet
-supported on logical volumes that are part of partial or clustered volume groups.
+activation/auto_activation_volume_list set in lvm.conf. If this list is not set, then
+all volumes are considered for autoactivation. The autoactivation is not yet
+supported for logical volumes that are part of partial or clustered volume groups.
 .TP
 .BR \-\-cache " [" \-\-major " " \fImajor " " \-\-minor " " \fIminor " | " \fIDevicePath " ]..."
 Scan one or more devices and instruct the lvmetad daemon to update its cached
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 0f5fc58..bc4ef32 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -70,8 +70,9 @@ group for input/output.
 In other words, makes the logical volumes known/unknown to the kernel.
 If autoactivation option is used (\-aay), each logical volume in
 the volume group is activated only if it matches an item in the
-activation/auto_activation_volume_list set in lvm.conf.
-Autoactivation is not yet supported for partial or clustered
+activation/auto_activation_volume_list set in lvm.conf. If this
+list is not set, then all volumes are considered for autoactivation.
+The autoactivation is not yet supported for partial or clustered
 volume groups.
 .IP
 If clustered locking is enabled, add 'e' to activate/deactivate


