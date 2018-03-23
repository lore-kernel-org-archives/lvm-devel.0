From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Mar 2018 12:25:42 -0400
Subject: master - libdm: enhance mounted fs detection
Message-ID: <201803231625.w2NGPg2e031900@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30975a3328a0d101dda935644349dac58e2fb97f
Commit:        30975a3328a0d101dda935644349dac58e2fb97f
Parent:        8c02cc9e8ffba777a92d798ca08c60e73dd2c109
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 20 11:13:22 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 23 17:24:58 2018 +0100

libdm: enhance mounted fs detection

btrfs is using fake major:minor device numbers.
try to be smarter and detect used node via DM device name.

This shortens delays, where i.e. lvm2 is asked to deactivate
volume with mounted btrfs as such operation is not retryed
and user is informed about device being in use.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |   30 ++++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 34c6833..d3cdf7d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.147 - 
 =====================================
+  Recognize also mounted btrfs through dm_device_has_mounted_fs().
   Add missing log_error() into dm_stats_populate() returning 0.
   Avoid calling dm_stats_populat() for DM devices without any stats regions.
   Support DM_DEBUG_WITH_LINE_NUMBERS envvar for debug msg with source:line.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 99cf0c8..094e618 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1742,6 +1742,10 @@ static int _mountinfo_parse_line(const char *line, unsigned *maj, unsigned *min,
 {
 	char root[PATH_MAX + 1]; /* sscanf needs extra '\0' */
 	char target[PATH_MAX + 1];
+	char *devmapper;
+	struct dm_task *dmt;
+	struct dm_info info;
+	unsigned i;
 
 	/* TODO: maybe detect availability of  %ms  glib support ? */
 	if (sscanf(line, "%*u %*u %u:%u %" DM_TO_STRING(PATH_MAX)
@@ -1751,6 +1755,32 @@ static int _mountinfo_parse_line(const char *line, unsigned *maj, unsigned *min,
 		return 0;
 	}
 
+	/* btrfs fakes device numbers, but there is still /dev/mapper name
+	 * placed in mountinfo, so try to detect proper major:minor via this */
+	if (*maj == 0 && (devmapper = strstr(line, "/dev/mapper/"))) {
+		if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
+			log_error("Mount info task creation failed.");
+			return 0;
+		}
+		devmapper += 12; /* skip fixed prefix */
+		for (i = 0; devmapper[i] && devmapper[i] != ' ' && i < sizeof(root); ++i)
+			root[i] = devmapper[i];
+		root[i] = 0;
+		_unmangle_mountinfo_string(root, buf);
+		buf[DM_NAME_LEN] = 0; /* cut away */
+
+		if (dm_task_set_name(dmt, buf) &&
+		    dm_task_no_open_count(dmt) &&
+		    dm_task_run(dmt) &&
+		    dm_task_get_info(dmt, &info)) {
+			log_debug("Replacing mountinfo device (%u:%u) with matching DM device %s (%u:%u).",
+				  *maj, *min, buf, info.major, info.minor);
+			*maj = info.major;
+			*min = info.minor;
+		}
+		dm_task_destroy(dmt);
+	}
+
 	_unmangle_mountinfo_string(target, buf);
 
 	return 1;


