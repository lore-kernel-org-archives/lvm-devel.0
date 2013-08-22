From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 22 Aug 2013 06:29:41 +0000 (UTC)
Subject: master - conf: more comments about use_lvmetad + autoactivation relation
Message-ID: <20130822062941.64FF060DF5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be9f4c77c93f347131f46a128013b0f4af8e5b32
Commit:        be9f4c77c93f347131f46a128013b0f4af8e5b32
Parent:        99fe3b88d270fa310d05dd093bea6dd74dc75642
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 22 08:26:35 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 22 08:29:20 2013 +0200

conf: more comments about use_lvmetad + autoactivation relation

---
 conf/example.conf.in |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 78c69e5..b99f010 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -541,15 +541,24 @@ global {
 
     # Whether to use (trust) a running instance of lvmetad. If this is set to
     # 0, all commands fall back to the usual scanning mechanisms. When set to 1
-    # *and* when lvmetad is running (it is not auto-started), the volume group
-    # metadata and PV state flags are obtained from the lvmetad instance and no
-    # scanning is done by the individual commands. In a setup with lvmetad,
-    # lvmetad udev rules *must* be set up for LVM to work correctly. Without
-    # proper udev rules, all changes in block device configuration will be
-    # *ignored* until a manual 'pvscan --cache' is performed.
+    # *and* when lvmetad is running (automatically instantiated by making use of
+    # systemd's socket-based service activation or run as an initscripts service
+    # or run manually), the volume group metadata and PV state flags are obtained
+    # from the lvmetad instance and no scanning is done by the individual
+    # commands. In a setup with lvmetad, lvmetad udev rules *must* be set up for
+    # LVM to work correctly. Without proper udev rules, all changes in block
+    # device configuration will be *ignored* until a manual 'pvscan --cache'
+    # is performed. These rules are installed by default.
     #
     # If lvmetad has been running while use_lvmetad was 0, it MUST be stopped
     # before changing use_lvmetad to 1 and started again afterwards.
+    #
+    # If using lvmetad, the volume activation is also switched to automatic
+    # event-based mode. In this mode, the volumes are activated based on
+    # incoming udev events that automatically inform lvmetad about new PVs
+    # that appear in the system. Once the VG is complete (all the PVs are
+    # present), it is auto-activated. The activation/auto_activation_volume_list
+    # setting controls which volumes are auto-activated (all by default).
     use_lvmetad = 0
 
     # Full path of the utility called to check that a thin metadata device


