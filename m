From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 16 Sep 2013 14:29:40 +0000 (UTC)
Subject: master - doc: add a note about device filtering while lvmetad is used
Message-ID: <20130916142940.700B660E91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10bc19ec1070d16d7367285856ebba7f99cf1996
Commit:        10bc19ec1070d16d7367285856ebba7f99cf1996
Parent:        61427af377891b011089b14154fe0c1d2845fd21
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 16 16:28:28 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 16 16:29:33 2013 +0200

doc: add a note about device filtering while lvmetad is used

---
 conf/example.conf.in |   12 ++++++++++++
 man/pvscan.8.in      |    3 ++-
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index b99f010..fb96079 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -80,6 +80,8 @@ devices {
     # the cache file gets regenerated (see below).
     # If it doesn't do what you expect, check the output of 'vgscan -vvvv'.
 
+    # If lvmetad is used, then see "A note about device filtering while
+    # lvmetad is used" comment that is attached to global/use_lvmetad setting.
 
     # By default we accept every block device:
     filter = [ "a/.*/" ]
@@ -559,6 +561,16 @@ global {
     # that appear in the system. Once the VG is complete (all the PVs are
     # present), it is auto-activated. The activation/auto_activation_volume_list
     # setting controls which volumes are auto-activated (all by default).
+    #
+    # A note about device filtering while lvmetad is used:
+    # When lvmetad is updated (either automatically based on udev events
+    # or directly by pvscan --cache <device> call), the devices/filter
+    # is ignored and all devices are scanned by default. The lvmetad always
+    # keeps unfiltered information which is then provided to LVM commands
+    # and then each LVM command does the filtering based on devices/filter
+    # setting itself.
+    # To prevent scanning devices completely, even when using lvmetad,
+    # the devices/global_filter must be used.
     use_lvmetad = 0
 
     # Full path of the utility called to check that a thin metadata device
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index 78ee3e2..211c82b 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -59,7 +59,8 @@ Run the command in the background.
 Scan one or more devices and instruct the lvmetad daemon to update its cached
 state accordingly.  Called internally by udev rules.
 All devices listed explicitly are processed \fBregardless\fP of any device
-filters set in lvm.conf.
+filters set using \fBdevices/filter\fP configuration setting. To filter
+devices even in this case, the \fBdevices/global_filter\fP must be used.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8),


