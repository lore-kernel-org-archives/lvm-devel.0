From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  9 Sep 2020 13:17:51 +0000 (GMT)
Subject: master - man: correctly use configured directories
Message-ID: <20200909131751.97C863857C68@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=763342016c2ca408bc3505ea4a14d0d22c610839
Commit:        763342016c2ca408bc3505ea4a14d0d22c610839
Parent:        af33a008472c5d7066a52f5c2031ce5b0d508a26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 9 13:22:37 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 9 13:22:37 2020 +0200

man: correctly use configured directories

---
 man/lvmdump.8_main  | 4 ++--
 man/lvmlockd.8_main | 2 +-
 man/lvmthin.7_main  | 6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/man/lvmdump.8_main b/man/lvmdump.8_main
index 2e80ed289..cbd5f15ef 100644
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
@@ -97,7 +97,7 @@ database content (the output of 'udevadm info --export-db' command).
 \fBLVM_BINARY\fP
 The LVM2 binary to use.
 Defaults to "lvm".
-Sometimes you might need to set this to "/sbin/lvm.static", for example.
+Sometimes you might need to set this to "#LVM_PATH#/lvm.static", for example.
 .TP
 \fBDMSETUP_BINARY\fP
 The dmsetup binary to use.
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index c21f7a916..f4c504d70 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -115,7 +115,7 @@ use_lvmlockd = 1
 .br
 Assign each host a unique host_id in the range 1-2000 by setting
 .br
-/etc/lvm/lvmlocal.conf local/host_id
+#DEFAULT_SYS_DIR#/lvmlocal.conf local/host_id
 
 .SS 3. start lvmlockd
 
diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index 84256141d..ce2343183 100644
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


