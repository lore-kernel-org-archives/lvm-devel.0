From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:41 +0000 (UTC)
Subject: dev-mornfall-activate - libdm: introduce dm_mountinfo_read
Message-ID: <20130604192641.B8D2160D78@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f30e5a0522a69aac0d246d2fb4e5ce2f6872cff
Commit:        1f30e5a0522a69aac0d246d2fb4e5ce2f6872cff
Parent:        d96b854ac054aafc8a9981016faefb9f122fccbb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 16 11:34:26 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 20 16:28:30 2013 +0200

libdm: introduce dm_mountinfo_read

Add function for parsing /proc/self/mountinfo entries.
This can be used to detected mounted device.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |   13 ++++++++
 libdm/libdm-common.c |   77 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 39ebcb2..8bdbfab 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Add dm_mountinfo_read() for parsing /proc/self/mountinfo.
   Report error for nonexisting devices in dmeventd communication.
   Prevent double free error after dmeventd call of _fill_device_data().
   Update dmevent structure message_data to simplify/fix error path handling.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index b729846..d9cd280 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -417,6 +417,19 @@ int dm_device_has_mounted_fs(uint32_t major, uint32_t minor);
 
 
 /*
+ * Callback is invoked for individal mountinfo lines,
+ * minor, major and mount target are parsed and unmangled.
+ */
+typedef int (*dm_mountinfo_line_callback_fn) (char *line, unsigned maj, unsigned min,
+					      char *target, void *cb_data);
+
+/*
+ * Read all lines from /proc/self/mountinfo,
+ * for each line calls read_fn callback.
+ */
+int dm_mountinfo_read(dm_mountinfo_line_callback_fn read_fn, void *cb_data);
+
+/*
  * Initialise library
  */
 void dm_lib_init(void) __attribute__((constructor));
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 4736b59..9e8ca25 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -62,6 +62,7 @@ union semun
 static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
 static char _sysfs_dir[PATH_MAX] = "/sys/";
 static char _path0[PATH_MAX];           /* path buffer, safe 4kB on stack */
+static const char _mountinfo[] = "/proc/self/mountinfo";
 
 #define DM_MAX_UUID_PREFIX_LEN	15
 static char _default_uuid_prefix[DM_MAX_UUID_PREFIX_LEN + 1] = "LVM-";
@@ -1571,6 +1572,82 @@ const char *dm_uuid_prefix(void)
 	return _default_uuid_prefix;
 }
 
+static int _is_octal(int a)
+{
+	return (((a) & ~7) == '0');
+}
+
+/* Convert mangled mountinfo into normal ASCII string */
+static void _unmangle_mountinfo_string(const char *src, char *buf)
+{
+	while (*src) {
+		if ((*src == '\\') &&
+		    _is_octal(src[1]) && _is_octal(src[2]) && _is_octal(src[3])) {
+			*buf++ = 64 * (src[1] & 7) + 8 * (src[2] & 7) + (src[3] & 7);
+			src += 4;
+		} else
+			*buf++ = *src++;
+	}
+	*buf = '\0';
+}
+
+/* Macros to make string defines */
+#define TO_STRING_EXP(A) #A
+#define TO_STRING(A) TO_STRING_EXP(A)
+
+/* Parse one line of mountinfo and unmangled target line */
+static int _mountinfo_parse_line(const char *line, unsigned *maj, unsigned *min, char *buf)
+{
+	char root[PATH_MAX + 1];
+	char target[PATH_MAX + 1];
+
+	/* TODO: maybe detect availability of  %ms  glib support ? */
+	if (sscanf(line, "%*u %*u %u:%u %" TO_STRING(PATH_MAX)
+		   "s %" TO_STRING(PATH_MAX) "s",
+		   maj, min, root, target) < 4) {
+		log_error("Failed to parse mountinfo line.");
+		return 0;
+	}
+
+	_unmangle_mountinfo_string(target, buf);
+
+	return 1;
+}
+
+/*
+ * Function to operate on individal mountinfo line,
+ * minor, major and mount target are parsed and unmangled
+ */
+int dm_mountinfo_read(dm_mountinfo_line_callback_fn read_fn, void *cb_data)
+{
+	FILE *minfo;
+	char buffer[2 * PATH_MAX];
+	char target[PATH_MAX];
+	unsigned maj, min;
+	int r = 1;
+
+	if (!(minfo = fopen(_mountinfo, "r"))) {
+		if (errno != ENOENT)
+			log_sys_error("fopen", _mountinfo);
+		else
+			log_sys_debug("fopen", _mountinfo);
+		return 0;
+	}
+
+	while (!feof(minfo) && fgets(buffer, sizeof(buffer), minfo))
+		if (!_mountinfo_parse_line(buffer, &maj, &min, target) ||
+		    !read_fn(buffer, maj, min, target, cb_data)) {
+			stack;
+			r = 0;
+			break;
+		}
+
+	if (fclose(minfo))
+		log_sys_error("fclose", _mountinfo);
+
+	return r;
+}
+
 static int _sysfs_get_dm_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
 {
 	char *sysfs_path, *temp_buf = NULL;


