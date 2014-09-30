From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 30 Sep 2014 09:40:57 +0000 (UTC)
Subject: master - conf: Update comments on lvmetad+filters in example.conf.in.
Message-ID: <20140930094057.7F59360E00@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fbc28cc7adb453122b83a18361809152bdee263f
Commit:        fbc28cc7adb453122b83a18361809152bdee263f
Parent:        9f3c11b39acc4252d6d40ae040319f66f9060a75
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 11:39:07 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Sep 30 11:39:07 2014 +0200

conf: Update comments on lvmetad+filters in example.conf.in.

---
 conf/example.conf.in |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 511ca0b..dd1d066 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -678,26 +678,31 @@ global {
     # If lvmetad has been running while use_lvmetad was 0, it MUST be stopped
     # before changing use_lvmetad to 1 and started again afterwards.
     #
-    # If using lvmetad, the volume activation is also switched to automatic
+    # If using lvmetad, volume activation is also switched to automatic
     # event-based mode. In this mode, the volumes are activated based on
-    # incoming udev events that automatically inform lvmetad about new PVs
-    # that appear in the system. Once the VG is complete (all the PVs are
-    # present), it is auto-activated. The activation/auto_activation_volume_list
-    # setting controls which volumes are auto-activated (all by default).
-    #
+    # incoming udev events that automatically inform lvmetad about new PVs that
+    # appear in the system. Once a VG is complete (all the PVs are present), it
+    # is auto-activated. The activation/auto_activation_volume_list setting
+    # controls which volumes are auto-activated (all by default).
+
     # A note about device filtering while lvmetad is used:
-    # When lvmetad is updated (either automatically based on udev events
-    # or directly by pvscan --cache <device> call), the devices/filter
-    # is ignored and all devices are scanned by default. The lvmetad always
-    # keeps unfiltered information which is then provided to LVM commands
-    # and then each LVM command does the filtering based on devices/filter
-    # setting itself.
-    # To prevent scanning devices completely, even when using lvmetad,
-    # the devices/global_filter must be used.
+
+    # When lvmetad is updated (either automatically based on udev events or
+    # directly by a pvscan --cache <device> call), devices/filter is ignored and
+    # all devices are scanned by default -- lvmetad always keeps unfiltered
+    # information which is then provided to LVM commands and then each LVM
+    # command does the filtering based on devices/filter setting itself.  This
+    # does not apply to non-regexp filters though: component filters such as
+    # multipath and MD are checked at pvscan --cache time.
+
+    # In order to completely prevent LVM from scanning a device, even when using
+    # lvmetad, devices/global_filter must be used.
+
     # N.B. Don't use lvmetad with locking type 3 as lvmetad is not yet
     # supported in clustered environment. If use_lvmetad=1 and locking_type=3
     # is set at the same time, LVM always issues a warning message about this
-    # and then it automatically disables lvmetad use.
+    # and then it automatically disables use_lvmetad.
+
     use_lvmetad = 0
 
     # Full path of the utility called to check that a thin metadata device


