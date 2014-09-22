From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:14 +0000 (UTC)
Subject: dev-dct-process-latest - revert: commit 3880ca5ecad1761bd13a190c58f8f85fdd7cd0e1
Message-ID: <20140922153814.3467760D38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25ae9383bbdec063257f67ac2dee8defd24aa2cf
Commit:        25ae9383bbdec063257f67ac2dee8defd24aa2cf
Parent:        ae08a3a2945b277af81a4cff42c6dcfb26f12fae
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 12 15:16:08 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 12 15:28:51 2014 +0200

revert: commit 3880ca5ecad1761bd13a190c58f8f85fdd7cd0e1

There's a better solution to this...
---
 WHATS_NEW_DM              |    1 -
 libdm/ioctl/libdm-iface.c |   40 +++++++++++-----------------------------
 2 files changed, 11 insertions(+), 30 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1374934..4effe09 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,5 @@
 Version 1.02.91 - 
 ====================================
-  Use dm-mod autoloading during dm_is_dm_major call if needed (kernels>=2.6.36).
 
 Version 1.02.90 - 1st September 2014
 ====================================
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 9350912..7d50f3a 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -336,6 +336,17 @@ static int _create_dm_bitset(void)
 #endif
 }
 
+int dm_is_dm_major(uint32_t major)
+{
+	if (!_create_dm_bitset())
+		return 0;
+
+	if (_dm_multiple_major_support)
+		return dm_bit(_dm_bitset, major) ? 1 : 0;
+	else
+		return (major == _dm_device_major) ? 1 : 0;
+}
+
 static void _close_control_fd(void)
 {
 	if (_control_fd != -1) {
@@ -412,35 +423,6 @@ bad:
 #endif
 }
 
-int dm_is_dm_major(uint32_t major)
-{
-	/*
-	 * If dm-mod module is not loaded yet during this call, we
-	 * can make it to load automatically in kernels >= 2.6.36
-	 * just by opening the dm control device. However, in older
-	 * kernels, there's nothing else we can do here - dm_is_dm_major
-	 * will fail as it can't determine this without the module
-	 * being loaded first - there's an error message issued for
-	 * this scenario deeper in this code.
-	 */
-	if (!_uname())
-		return 0;
-
-	if (KERNEL_VERSION(_kernel_major, _kernel_minor, _kernel_release) >=
-	    KERNEL_VERSION(2, 6, 36)) {
-		if (_control_fd == -1 && !_open_control())
-			return 0;
-	}
-
-	if (!_create_dm_bitset())
-		return 0;
-
-	if (_dm_multiple_major_support)
-		return dm_bit(_dm_bitset, major) ? 1 : 0;
-	else
-		return (major == _dm_device_major) ? 1 : 0;
-}
-
 static void _dm_zfree_string(char *string)
 {
 	if (string) {


