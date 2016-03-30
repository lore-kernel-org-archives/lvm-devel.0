From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Mar 2016 12:11:10 +0000 (UTC)
Subject: master - doc: describe lvmlockd/lvmpolld features as available if LVM compiled with lockd/polld support
Message-ID: <20160330121110.14AA160DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06ef7ba8765d64044b008a33f1c1faeac6112a4a
Commit:        06ef7ba8765d64044b008a33f1c1faeac6112a4a
Parent:        8b258a005ba6852209ec7af5b373a69f437abfaa
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 30 14:10:56 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 30 14:10:56 2016 +0200

doc: describe lvmlockd/lvmpolld features as available if LVM compiled with lockd/polld support

---
 conf/example.conf.in         |    9 +++++++--
 conf/lvmlocal.conf.in        |    1 +
 lib/config/config_settings.h |   16 +++++++++++-----
 man/lvm.8.in                 |    3 ++-
 man/lvmsystemid.7.in         |    6 ++++--
 man/vgchange.8.in            |    4 ++--
 man/vgcreate.8.in            |    8 ++++----
 7 files changed, 31 insertions(+), 16 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index a21dd96..255d329 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -853,11 +853,14 @@ global {
 
 	# Configuration option global/use_lvmlockd.
 	# Use lvmlockd for locking among hosts using LVM on shared storage.
-	# See lvmlockd(8) for more information.
+	# Applicable only if LVM is compiled with lockd support in which
+	# case there is also lvmlockd(8) man page available for more
+	# information.
 	use_lvmlockd = 0
 
 	# Configuration option global/lvmlockd_lock_retries.
 	# Retry lvmlockd lock requests this many times.
+	# Applicable only if LVM is compiled with lockd support
 	# This configuration option has an automatic default value.
 	# lvmlockd_lock_retries = 3
 
@@ -867,7 +870,8 @@ global {
 	# LVs have been created, the internal LV needs to be extended. lvcreate
 	# will automatically extend the internal LV when needed by the amount
 	# specified here. Setting this to 0 disables the automatic extension
-	# and can cause lvcreate to fail.
+	# and can cause lvcreate to fail. Applicable only if LVM is compiled
+	# with lockd support
 	# This configuration option has an automatic default value.
 	# sanlock_lv_extend = 256
 
@@ -1014,6 +1018,7 @@ global {
 	# a native systemd service, which allows it to be started on demand,
 	# and to use its own control group. When this option is disabled, LVM
 	# commands will supervise long running operations by forking themselves.
+	# Applicable only if LVM is compiled with lvmpolld support.
 	use_lvmpolld = @DEFAULT_USE_LVMPOLLD@
 
 	# Configuration option global/notify_dbus.
diff --git a/conf/lvmlocal.conf.in b/conf/lvmlocal.conf.in
index 9fc50c8..04414bf 100644
--- a/conf/lvmlocal.conf.in
+++ b/conf/lvmlocal.conf.in
@@ -51,6 +51,7 @@ local {
 	# Configuration option local/host_id.
 	# The lvmlockd sanlock host_id.
 	# This must be unique among all hosts, and must be between 1 and 2000.
+	# Applicable only if LVM is compiled with lockd support
 	# This configuration option has an automatic default value.
 	# host_id = 0
 }
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d58b7a4..330e223 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -856,10 +856,13 @@ cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL,
 
 cfg(global_use_lvmlockd_CFG, "use_lvmlockd", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
 	"Use lvmlockd for locking among hosts using LVM on shared storage.\n"
-	"See lvmlockd(8) for more information.\n")
+	"Applicable only if LVM is compiled with lockd support in which\n"
+	"case there is also lvmlockd(8) man page available for more\n"
+	"information.\n")
 
 cfg(global_lvmlockd_lock_retries_CFG, "lvmlockd_lock_retries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LVMLOCKD_LOCK_RETRIES, vsn(2, 2, 125), NULL, 0, NULL,
-	"Retry lvmlockd lock requests this many times.\n")
+	"Retry lvmlockd lock requests this many times.\n"
+	"Applicable only if LVM is compiled with lockd support\n")
 
 cfg(global_sanlock_lv_extend_CFG, "sanlock_lv_extend", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_SANLOCK_LV_EXTEND_MB, vsn(2, 2, 124), NULL, 0, NULL,
 	"Size in MiB to extend the internal LV holding sanlock locks.\n"
@@ -867,7 +870,8 @@ cfg(global_sanlock_lv_extend_CFG, "sanlock_lv_extend", global_CFG_SECTION, CFG_D
 	"LVs have been created, the internal LV needs to be extended. lvcreate\n"
 	"will automatically extend the internal LV when needed by the amount\n"
 	"specified here. Setting this to 0 disables the automatic extension\n"
-	"and can cause lvcreate to fail.\n")
+	"and can cause lvcreate to fail. Applicable only if LVM is compiled\n"
+	"with lockd support\n")
 
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), "@THIN_CHECK_CMD@", 0, NULL,
 	"The full path to the thin_check command.\n"
@@ -993,7 +997,8 @@ cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, 0, CFG_TYPE_BOO
 	"manage the progress of ongoing operations. lvmpolld can be used as\n"
 	"a native systemd service, which allows it to be started on demand,\n"
 	"and to use its own control group. When this option is disabled, LVM\n"
-	"commands will supervise long running operations by forking themselves.\n")
+	"commands will supervise long running operations by forking themselves.\n"
+	"Applicable only if LVM is compiled with lvmpolld support.\n")
 
 cfg(global_notify_dbus_CFG, "notify_dbus", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_NOTIFY_DBUS, vsn(2, 2, 145), NULL, 0, NULL,
 	"Enable D-Bus notification from LVM commands.\n"
@@ -1779,6 +1784,7 @@ cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG
 
 cfg(local_host_id_CFG, "host_id", local_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(2, 2, 124), NULL, 0, NULL,
 	"The lvmlockd sanlock host_id.\n"
-	"This must be unique among all hosts, and must be between 1 and 2000.\n")
+	"This must be unique among all hosts, and must be between 1 and 2000.\n"
+	"Applicable only if LVM is compiled with lockd support\n")
 
 cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL, 0, NULL, NULL)
diff --git a/man/lvm.8.in b/man/lvm.8.in
index fd25001..d2da72c 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -373,7 +373,8 @@ is not used and metadata is read from disks.
 .br
 Cause the command to access shared VGs, that would otherwise be skipped
 when lvmlockd is not being used.  It can be used to report or display a
-lockd VG without locking.
+lockd VG without locking. Applicable only if LVM is compiled with lockd
+support.
 .
 .HP
 .BR \-\-addtag
diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index 0048873..3aea996 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -111,7 +111,8 @@ owned.
 .B Shared:
 A shared or "lockd" VG has lock_type set and no system_id.
 A shared VG is meant to be used on shared storage from multiple hosts,
-and is only accessible to hosts using lvmlockd.
+and is only accessible to hosts using lvmlockd. Applicable only if LVM
+is compiled with lockd support.
 
 .B Clustered:
 A clustered or "clvm" VG has the clustered flag set and no system_id.
@@ -308,7 +309,8 @@ extra_system_ids list.
 
 A shared/lockd VG has no system_id set, allowing multiple hosts to
 use it via lvmlockd.  Changing a VG to a lockd type will clear the
-existing system_id.
+existing system_id. Applicable only if LVM is compiled with lockd
+support.
 
 .SS clustered VGs
 
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 6e13f5f..e334fd1 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -132,8 +132,8 @@ be used on one node at once.
 
 For local VGs, \-ay, \-aey, and \-asy are all equivalent.
 .IP
-In a shared VG, lvmlockd is used for locking, and the following options
-are possible:
+In a shared VG, lvmlockd is used for locking if LVM is compiled with lockd
+support, and the following options are possible:
 
 With \-aey, the command activates the LV in exclusive mode, allowing a
 single host to activate the LV (the host running the command).  Before
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index 22feedf..b0b01e4 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -130,10 +130,10 @@ The 2.4 kernel has a limitation of 2TiB per block device.
 
 .TP
 .B \-\-shared
-Create a shared VG using lvmlockd.  lvmlockd will select lock type sanlock
-or dlm depending on which lock manager is running.  This allows multiple
-hosts to share a VG on shared devices.  lvmlockd and a lock manager must
-be configured and running.  See
+Create a shared VG using lvmlockd if LVM is copiled with lockd support.
+ lvmlockd will select lock type sanlock or dlm depending on which lock
+manager is running.  This allows multiple hosts to share a VG on shared
+devices.  lvmlockd and a lock manager must be configured and running.  See
 .BR lvmlockd (8).
 
 .TP


