From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 20 Aug 2015 16:28:48 +0000 (UTC)
Subject: master - libdm: add dm_message_supports_precise_timestamps()
Message-ID: <20150820162848.F2668602B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=386e91addbaffcaae20f4f20084cb06b7374e402
Commit:        386e91addbaffcaae20f4f20084cb06b7374e402
Parent:        62a87c84edc12788a088b3cc7dc5a35a18951f38
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Aug 18 16:37:03 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Aug 20 12:11:23 2015 +0100

libdm: add dm_message_supports_precise_timestamps()

Add a function to test whether the kernel precise_timestamps
feature is available in the current device-mapper driver version.

Presence of precise_timestamps also implies the availability of
latency histograms.
---
 libdm/.exported_symbols.DM_1_02_106 |    1 +
 libdm/ioctl/libdm-iface.c           |   14 ++++++++++++++
 libdm/libdevmapper.h                |    9 +++++++++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_106 b/libdm/.exported_symbols.DM_1_02_106
new file mode 100644
index 0000000..0ce8924
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_106
@@ -0,0 +1 @@
+dm_message_supports_precise_timestamps
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 73af12b..fe0bffa 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -604,6 +604,20 @@ static int dm_inactive_supported(void)
 	return inactive_supported;
 }
 
+int dm_message_supports_precise_timestamps(void)
+{
+	/*
+	 * 4.32.0 supports "precise_timestamps" and "histogram:" options
+	 * to @stats_create messages but lacks the ability to report
+	 * these properties via a subsequent @stats_list: require at
+	 * least 4.33.0 in order to use these features.
+	 */
+	if (dm_check_version() && _dm_version >= 4)
+		if (_dm_version_minor >= 33)
+			return 1;
+	return 0;
+}
+
 void *dm_get_next_target(struct dm_task *dmt, void *next,
 			 uint64_t *start, uint64_t *length,
 			 char **target_type, char **params)
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index af08ba3..2be2ce3 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -464,6 +464,15 @@ int dm_stats_bind_name(struct dm_stats *dms, const char *name);
  */
 int dm_stats_bind_uuid(struct dm_stats *dms, const char *uuid);
 
+/*
+ * Test whether the running kernel supports the precise_timestamps
+ * feature. Presence of this feature also implies histogram support.
+ * The library will check this call internally and fails any attempt
+ * to use nanosecond counters or histograms on kernels that fail to
+ * meet this check.
+ */
+int dm_message_supports_precise_timestamps(void);
+
 #define DM_STATS_ALL_PROGRAMS ""
 /*
  * Parse the response from a @stats_list message. dm_stats_list will


