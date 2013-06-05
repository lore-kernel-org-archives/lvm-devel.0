From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:47 +0000 (UTC)
Subject: dev-mornfall-lvmcache - libdm: improve detection of mounted fs
Message-ID: <20130605120347.787AC6116D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7fab9a9dda12a0d40688de5a7b57f6d7234e0f2c
Commit:        7fab9a9dda12a0d40688de5a7b57f6d7234e0f2c
Parent:        1f30e5a0522a69aac0d246d2fb4e5ce2f6872cff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 16 11:55:51 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 20 16:47:31 2013 +0200

libdm: improve detection of mounted fs

To detect mounted device, use also /proc/self/mountinfo
as so far the check was only able to detect ext4 mounted filesystem.

TODO:
Once proper testing for this feature is added, it may appear,
mountinfo check is enough and covers all cases and sysfs check
could be removed.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8bdbfab..9132e01 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Detecte mounted fs also via reading /proc/self/mountinfo.
   Add dm_mountinfo_read() for parsing /proc/self/mountinfo.
   Report error for nonexisting devices in dmeventd communication.
   Prevent double free error after dmeventd call of _fill_device_data().
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 9e8ca25..4b0ba08 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1842,10 +1842,48 @@ static int _mounted_fs_on_device(const char *kernel_dev_name)
 	return r;
 }
 
+struct mountinfo_s {
+	unsigned maj;
+	unsigned min;
+	int mounted;
+};
+
+static int _device_has_mounted_fs(char *buffer, unsigned major, unsigned minor,
+				  char *target, void *cb_data)
+{
+	struct mountinfo_s *data = cb_data;
+	char kernel_dev_name[PATH_MAX];
+
+	if ((major == data->maj) && (minor == data->min)) {
+		if (!dm_device_get_name(major, minor, 1, kernel_dev_name, PATH_MAX)) {
+			stack;
+			*kernel_dev_name = '\0';
+		}
+		log_verbose("Device %s (%u:%u) appears to be mounted on %s.",
+			    kernel_dev_name, major, minor, target);
+		data->mounted = 1;
+	}
+
+	return 1;
+}
+
 int dm_device_has_mounted_fs(uint32_t major, uint32_t minor)
 {
 	char kernel_dev_name[PATH_MAX];
+	struct mountinfo_s data = {
+		.maj = major,
+		.min = minor,
+	};
+
+	if (!dm_mountinfo_read(_device_has_mounted_fs, &data))
+		stack;
 
+	if (data.mounted)
+		return 1;
+	/*
+	 * TODO: Verify dm_mountinfo_read() is superset
+	 * and remove sysfs check (namespaces)
+	 */
 	/* Get kernel device name first */
 	if (!dm_device_get_name(major, minor, 1, kernel_dev_name, PATH_MAX))
 		return 0;


