From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:24 +0000 (UTC)
Subject: master - libdm: add dm_hold_control_dev
Message-ID: <20151022213324.8DCFF60F00@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09a62cca0ce259b207e85683dae47ac145590825
Commit:        09a62cca0ce259b207e85683dae47ac145590825
Parent:        075f85dcb518d7d9c2452af4165f44ba991a1258
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 21 20:36:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:27:31 2015 +0200

libdm: add dm_hold_control_dev

Support hold of control device open.
Useful for daemons so the control device is not frequently reopenned.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_110 |    1 +
 libdm/ioctl/libdm-iface.c           |   12 +++++++++++-
 libdm/libdevmapper.h                |    3 +++
 4 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9818846..653e32d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Add dm_hold_control_dev to allow holding of control device open.
   Add dm_report_compact_given_fields to remove given empty fields from report.
   Use libdm status parsing and local mem raid dmeventd plugin.
   Use local mem pool and lock only lvm2 execution for mirror dmeventd plugin.
diff --git a/libdm/.exported_symbols.DM_1_02_110 b/libdm/.exported_symbols.DM_1_02_110
index 71d04a9..da742ee 100644
--- a/libdm/.exported_symbols.DM_1_02_110
+++ b/libdm/.exported_symbols.DM_1_02_110
@@ -1 +1,2 @@
 dm_report_compact_given_fields
+dm_hold_control_dev
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index e9566c2..58a8dfe 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -81,6 +81,7 @@ static dm_bitset_t _dm_bitset = NULL;
 static uint32_t _dm_device_major = 0;
 
 static int _control_fd = -1;
+static int _hold_control_fd_open = 0;
 static int _version_checked = 0;
 static int _version_ok = 1;
 static unsigned _ioctl_buffer_double_factor = 0;
@@ -2079,9 +2080,18 @@ repeat_ioctl:
 	return 0;
 }
 
+void dm_hold_control_dev(int hold_open)
+{
+	_hold_control_fd_open = hold_open ? 1 : 0;
+
+	log_debug("Hold of control device is now %sset.",
+		  _hold_control_fd_open ? "" : "un");
+}
+
 void dm_lib_release(void)
 {
-	_close_control_fd();
+	if (!_hold_control_fd_open)
+		_close_control_fd();
 	dm_timestamp_destroy(_dm_ioctl_timestamp);
 	_dm_ioctl_timestamp = NULL;
 	update_devs();
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index fcbf7cf..08b24fe 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1168,6 +1168,9 @@ void dm_lib_init(void) __attribute__((constructor));
 void dm_lib_release(void);
 void dm_lib_exit(void) __attribute__((destructor));
 
+/* An optimisation for clients making repeated calls involving dm ioctls */
+void dm_hold_control_dev(int hold_open);
+
 /*
  * Use NULL for all devices.
  */


