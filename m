From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  7 Jul 2015 12:11:43 +0000 (UTC)
Subject: master - conf: regenerate
Message-ID: <20150707121143.77CF76112A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b174c27d4dd0081396048102e0f6decb8cd569bd
Commit:        b174c27d4dd0081396048102e0f6decb8cd569bd
Parent:        bfd0689d6413437c6d3fb8a8461a22ff0f1b5dc9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 7 14:11:16 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 7 14:11:16 2015 +0200

conf: regenerate

---
 conf/example.conf.in  |   29 +++++++++++++++++++++++++++++
 conf/lvmlocal.conf.in |    6 ++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index a26066a..4d73c5c 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -821,6 +821,23 @@ global {
 	# is seen.
 	use_lvmetad = @DEFAULT_USE_LVMETAD@
 
+	# Configuration option global/use_lvmlockd.
+	# Use lvmlockd for locking among hosts using LVM on shared storage.
+	use_lvmlockd = 0
+
+	# Configuration option global/lvmlockd_lock_retries.
+	# Retry lvmlockd lock requests this many times.
+	# lvmlockd_lock_retries = 3
+
+	# Configuration option global/sanlock_lv_extend.
+	# Size in MiB to extend the internal LV holding sanlock locks.
+	# The internal LV holds locks for each LV in the VG, and after
+	# enough LVs have been created, the internal LV needs to be extended.
+	# lvcreate will automatically extend the internal LV when needed by
+	# the amount specified here.  Setting this to 0 disables the
+	# automatic extension and can cause lvcreate to fail.
+	# sanlock_lv_extend = 256
+
 	# Configuration option global/thin_check_executable.
 	# The full path to the thin_check command.
 	# LVM uses this command to check that a thin metadata
@@ -883,6 +900,8 @@ global {
 	# Also see cache_check_options.
 	# The cache tools are available from the package
 	# device-mapper-persistent-data.
+	# With cache_check version 5.0 or newer you should add
+	# --clear-needs-check-flag.
 	# cache_check_executable = "@CACHE_CHECK_CMD@"
 
 	# Configuration option global/cache_dump_executable.
@@ -1286,6 +1305,16 @@ activation {
 	# sometimes assist with data recovery.
 	# The '--activationmode' option overrides this setting.
 	activation_mode = "degraded"
+
+	# Configuration option activation/lock_start_list.
+	# Locking is started only for VGs selected by this list.
+	# The rules are the same as those for LVs in volume_list.
+	# This configuration option does not have a default value defined.
+
+	# Configuration option activation/auto_lock_start_list.
+	# Locking is auto-started only for VGs selected by this list.
+	# The rules are the same as those for LVs in auto_activation_volume_list.
+	# This configuration option does not have a default value defined.
 }
 
 # Configuration section metadata.
diff --git a/conf/lvmlocal.conf.in b/conf/lvmlocal.conf.in
index 0e82d5c..c3f6ac1 100644
--- a/conf/lvmlocal.conf.in
+++ b/conf/lvmlocal.conf.in
@@ -48,4 +48,10 @@ local {
 	# Use this only after consulting 'man lvmsystemid'
 	# to be certain of correct usage and possible dangers.
 	# This configuration option does not have a default value defined.
+
+	# Configuration option local/host_id.
+	# The lvmlockd sanlock host_id.
+	# This must be a unique among all hosts,
+	# and must be between 1 and 2000.
+	# host_id = 0
 }


