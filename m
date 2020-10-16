From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:08 +0000 (GMT)
Subject: stable-2.02 - man: correctly use configured directories
Message-ID: <20201016191108.B6B9C396EC82@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=68f94a2dd38da38d705051b055caf231ad6fb100
Commit:        68f94a2dd38da38d705051b055caf231ad6fb100
Parent:        6d2fc49e9957308e6c770c2a84f3a34b9b416d2b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 9 13:22:37 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

man: correctly use configured directories

---
 man/lvmdump.8_main  | 4 ++--
 man/lvmlockd.8_main | 2 +-
 man/lvmthin.7_main  | 6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/man/lvmdump.8_main b/man/lvmdump.8_main
index ec3dbb2ea..c42f80917 100644
--- a/man/lvmdump.8_main
+++ b/man/lvmdump.8_main
@@ -26,7 +26,7 @@ The content of the tarball is as follows:
 .br
 - recent entries from /var/log/messages (containing system messages)
 .br
-- complete lvm configuration and cache (content of /etc/lvm)
+- complete lvm configuration and cache (content of #DEFAULT_SYS_DIR#)
 .br
 - list of device nodes present under /dev
 .br
@@ -102,7 +102,7 @@ database content (the output of 'udevadm info --export-db' command).
 \fBLVM_BINARY\fP
 The LVM2 binary to use.
 Defaults to "lvm".
-Sometimes you might need to set this to "/sbin/lvm.static", for example.
+Sometimes you might need to set this to "#LVM_PATH#/lvm.static", for example.
 .TP
 \fBDMSETUP_BINARY\fP
 The dmsetup binary to use.
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index b917d9381..80c23b7ea 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -110,7 +110,7 @@ use_lvmlockd = 1
 .br
 Assign each host a unique host_id in the range 1-2000 by setting
 .br
-/etc/lvm/lvmlocal.conf local/host_id
+#DEFAULT_SYS_DIR#/lvmlocal.conf local/host_id
 
 .SS 3. start lvmlockd
 
diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index 27bad5731..5a2ccc440 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -902,7 +902,7 @@ To change these values globally, edit
 To change these values on a per-VG or per-LV basis, attach a "profile" to
 the VG or LV.  A profile is a collection of config settings, saved in a
 local text file (using the lvm.conf format).  lvm looks for profiles in
-the profile_dir directory, e.g. /etc/lvm/profile/.  Once attached to a VG
+the profile_dir directory, e.g. #DEFAULT_SYS_DIR#/profile/.  Once attached to a VG
 or LV, lvm will process the VG or LV using the settings from the attached
 profile.  A profile is named and referenced by its file name.
 
@@ -930,9 +930,9 @@ Extend the LV using the profile settings:
 .br
 .nf
 # lvmconfig config/profile_dir
-profile_dir="/etc/lvm/profile"
+profile_dir="#DEFAULT_SYS_DIR#/profile"
 
-# cat /etc/lvm/profile/pool0extend.profile
+# cat #DEFAULT_SYS_DIR#/profile/pool0extend.profile
 activation {
         thin_pool_autoextend_threshold=50
         thin_pool_autoextend_percent=10


