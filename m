From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Sep 2014 10:56:49 +0000 (UTC)
Subject: master - libdm: use dm-mod autoloading during dm_is_dm_major call if needed
Message-ID: <20140912105649.3B52360F3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3880ca5ecad1761bd13a190c58f8f85fdd7cd0e1
Commit:        3880ca5ecad1761bd13a190c58f8f85fdd7cd0e1
Parent:        f0cafc92812e285e5120241da04b5d119b27060b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 12 12:49:37 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 12 12:49:37 2014 +0200

libdm: use dm-mod autoloading during dm_is_dm_major call if needed

For dm_is_dm_major to determine whether the major number given as
an argument belongs to a DM device, libdm code needs to know what
the actual DM major is to do the comparison.

It may happen that the dm-mod module is not loaded during this
call and so for the completness let's try our best before we start
giving various errors - we can still make use of dm-mod autoloading,
though only since kernels 2.6.36 where this feature was introduced.
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |   40 +++++++++++++++++++++++++++++-----------
 2 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4effe09..1374934 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.91 - 
 ====================================
+  Use dm-mod autoloading during dm_is_dm_major call if needed (kernels>=2.6.36).
 
 Version 1.02.90 - 1st September 2014
 ====================================
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 7d50f3a..9350912 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -336,17 +336,6 @@ static int _create_dm_bitset(void)
 #endif
 }
 
-int dm_is_dm_major(uint32_t major)
-{
-	if (!_create_dm_bitset())
-		return 0;
-
-	if (_dm_multiple_major_support)
-		return dm_bit(_dm_bitset, major) ? 1 : 0;
-	else
-		return (major == _dm_device_major) ? 1 : 0;
-}
-
 static void _close_control_fd(void)
 {
 	if (_control_fd != -1) {
@@ -423,6 +412,35 @@ bad:
 #endif
 }
 
+int dm_is_dm_major(uint32_t major)
+{
+	/*
+	 * If dm-mod module is not loaded yet during this call, we
+	 * can make it to load automatically in kernels >= 2.6.36
+	 * just by opening the dm control device. However, in older
+	 * kernels, there's nothing else we can do here - dm_is_dm_major
+	 * will fail as it can't determine this without the module
+	 * being loaded first - there's an error message issued for
+	 * this scenario deeper in this code.
+	 */
+	if (!_uname())
+		return 0;
+
+	if (KERNEL_VERSION(_kernel_major, _kernel_minor, _kernel_release) >=
+	    KERNEL_VERSION(2, 6, 36)) {
+		if (_control_fd == -1 && !_open_control())
+			return 0;
+	}
+
+	if (!_create_dm_bitset())
+		return 0;
+
+	if (_dm_multiple_major_support)
+		return dm_bit(_dm_bitset, major) ? 1 : 0;
+	else
+		return (major == _dm_device_major) ? 1 : 0;
+}
+
 static void _dm_zfree_string(char *string)
 {
 	if (string) {


