From: David Teigland <teigland@sourceware.org>
Date: Fri, 22 Apr 2022 21:07:55 +0000 (GMT)
Subject: main - filter-mpath: use multipath blacklist
Message-ID: <20220422210755.4EFF53858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=494372b4eed0c8f6040e3357939eb7511ac25745
Commit:        494372b4eed0c8f6040e3357939eb7511ac25745
Parent:        5c50590b22b37055e93b571fb26d1854f73ae2fd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 21 13:45:01 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 22 16:07:47 2022 -0500

filter-mpath: use multipath blacklist

Explicit wwid's from these sections control whether the
same wwid in /etc/multipath/wwids is recognized as a
multipath component.  Other non-wwid keywords are not
used, and may require disabling the use of the multipath
wwids file in lvm.conf.
---
 lib/device/dev-mpath.c                | 181 +++++++++++++++++++++++++++++++---
 test/shell/duplicate-pvs-multipath.sh |   2 +-
 test/shell/multipath-config.sh        | 171 ++++++++++++++++++++++++++++++++
 3 files changed, 342 insertions(+), 12 deletions(-)

diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
index 808d5201f..270366ad7 100644
--- a/lib/device/dev-mpath.c
+++ b/lib/device/dev-mpath.c
@@ -17,12 +17,14 @@
 #include "lib/activate/activate.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/device/device_id.h"
+#include "lib/datastruct/str_list.h"
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
 #include "lib/device/dev-ext-udev-constants.h"
 #endif
 
 #include <dirent.h>
+#include <ctype.h>
 
 #define MPATH_PREFIX "mpath-"
 
@@ -35,15 +37,167 @@
  * If dm-3 is not an mpath device, then the constant "1" is stored in
  * the hash table with the key of the dm minor number.
  */
-static struct dm_pool *_hash_mem;
+static struct dm_pool *_wwid_mem;
 static struct dm_hash_table *_minor_hash_tab;
 static struct dm_hash_table *_wwid_hash_tab;
+static struct dm_list _ignored;
+static struct dm_list _ignored_exceptions;
 
 #define MAX_WWID_LINE 512
 
-/*
- * do we need to check the multipath.conf blacklist?
- */
+static void _read_blacklist_file(const char *path)
+{
+	FILE *fp;
+	char line[MAX_WWID_LINE];
+	char wwid[MAX_WWID_LINE];
+	char *word, *p;
+	int section_black = 0;
+	int section_exceptions = 0;
+	int found_quote;
+	int found_three;
+	int i, j;
+
+	if (!(fp = fopen(path, "r")))
+		return;
+
+	while (fgets(line, sizeof(line), fp)) {
+		word = NULL;
+
+		/* skip initial white space on the line */
+		for (i = 0; i < MAX_WWID_LINE; i++) {
+			if ((line[i] == '\n') || (line[i] == '\0'))
+				break;
+			if (isspace(line[i]))
+				continue;
+			word = &line[i];
+			break;
+		}
+
+		if (!word || word[0] == '#')
+			continue;
+
+		/* identify the start of the section we want to read */
+		if (strchr(word, '{')) {
+			if (!strncmp(word, "blacklist_exceptions", 20))
+				section_exceptions = 1;
+			else if (!strncmp(word, "blacklist", 9))
+				section_black = 1;
+			continue;
+		}
+		/* identify the end of the section we've been reading */
+		if (strchr(word, '}')) {
+			section_exceptions = 0;
+			section_black = 0;
+			continue;
+		}
+		/* skip lines that are not in a section we want */
+		if (!section_black && !section_exceptions)
+			continue;
+
+		/*
+		 * read a wwid from the blacklist{_exceptions} section.
+		 * does not recognize other non-wwid entries in the
+		 * section, and skips those (should the entire mp
+		 * config filtering be disabled if non-wwids are seen?
+		 */
+		if (!(p = strstr(word, "wwid")))
+			continue;
+
+		i += 4; /* skip "wwid" */
+
+		/*
+		 * copy wwid value from the line.
+		 * the wwids copied here need to match the
+		 * wwids read from /etc/multipath/wwids,
+		 * which are matched to wwids from sysfs.
+		 */
+
+		memset(wwid, 0, sizeof(wwid));
+		found_quote = 0;
+		found_three = 0;
+		j = 0;
+
+		for (; i < MAX_WWID_LINE; i++) {
+			if ((line[i] == '\n') || (line[i] == '\0'))
+				break;
+			if (!j && isspace(line[i]))
+				continue;
+			if (isspace(line[i]))
+				break;
+			/* quotes around wwid are optional */
+			if ((line[i] == '"') && !found_quote) {
+				found_quote = 1;
+				continue;
+			}
+			/* second quote is end of wwid */
+			if ((line[i] == '"') && found_quote)
+				break;
+			/* ignore first "3" in wwid */
+			if ((line[i] == '3') && !found_three) {
+				found_three = 1;
+				continue;
+			}
+
+			wwid[j] = line[i];
+			j++;
+		}
+
+		if (j < 8)
+			continue;
+
+		log_debug("multipath wwid %s in %s %s",
+			  wwid, section_exceptions ? "blacklist_exceptions" : "blacklist", path);
+
+		if (section_exceptions) {
+			if (!str_list_add(_wwid_mem, &_ignored_exceptions, dm_pool_strdup(_wwid_mem, wwid)))
+				stack;
+		} else {
+			if (!str_list_add(_wwid_mem, &_ignored, dm_pool_strdup(_wwid_mem, wwid)))
+				stack;
+		}
+	}
+
+	if (fclose(fp))
+		stack;
+}
+
+static void _read_wwid_exclusions(void)
+{
+	char path[PATH_MAX] = { 0 };
+	DIR *dir;
+	struct dirent *de;
+	struct dm_str_list *sl, *sl2;
+	int rem_count = 0;
+
+	_read_blacklist_file("/etc/multipath.conf");
+
+	if ((dir = opendir("/etc/multipath/conf.d"))) {
+		while ((de = readdir(dir))) {
+			if (de->d_name[0] == '.')
+				continue;
+			snprintf(path, PATH_MAX-1, "/etc/multipath/conf.d/%s", de->d_name);
+			_read_blacklist_file(path);
+		}
+		closedir(dir);
+	}
+
+	/* for each wwid in ignored_exceptions, remove it from ignored */
+
+	dm_list_iterate_items_safe(sl, sl2, &_ignored) {
+		if (str_list_match_item(&_ignored_exceptions, sl->str))
+			str_list_del(&_ignored, sl->str);
+	}
+
+	/* for each wwid in ignored, remove it from wwid_hash */
+
+	dm_list_iterate_items(sl, &_ignored) {
+		dm_hash_remove_binary(_wwid_hash_tab, sl->str, strlen(sl->str));
+		rem_count++;
+	}
+
+	if (rem_count)
+		log_debug("multipath config ignored %d wwids", rem_count);
+}
 
 static void _read_wwid_file(const char *config_wwids_file)
 {
@@ -93,6 +247,9 @@ int dev_mpath_init(const char *config_wwids_file)
 	struct dm_hash_table *minor_tab;
 	struct dm_hash_table *wwid_tab;
 
+	dm_list_init(&_ignored);
+	dm_list_init(&_ignored_exceptions);
+
 	if (!(mem = dm_pool_create("mpath", 256))) {
 		log_error("mpath pool creation failed.");
 		return 0;
@@ -104,7 +261,7 @@ int dev_mpath_init(const char *config_wwids_file)
 		return 0;
 	}
 
-	_hash_mem = mem;
+	_wwid_mem = mem;
 	_minor_hash_tab = minor_tab;
 
 	/* multipath_wwids_file="" disables the use of the file */
@@ -116,16 +273,18 @@ int dev_mpath_init(const char *config_wwids_file)
 	if (!(wwid_tab = dm_hash_create(110))) {
 		log_error("mpath hash table creation failed.");
 		dm_hash_destroy(_minor_hash_tab);
-		dm_pool_destroy(_hash_mem);
+		dm_pool_destroy(_wwid_mem);
 		_minor_hash_tab = NULL;
-		_hash_mem = NULL;
+		_wwid_mem = NULL;
 		return 0;
 	}
 
 	_wwid_hash_tab = wwid_tab;
 
-	if (config_wwids_file)
+	if (config_wwids_file) {
 		_read_wwid_file(config_wwids_file);
+		_read_wwid_exclusions();
+	}
 
 	return 1;
 }
@@ -136,12 +295,12 @@ void dev_mpath_exit(void)
 		dm_hash_destroy(_minor_hash_tab);
 	if (_wwid_hash_tab)
 		dm_hash_destroy(_wwid_hash_tab);
-	if (_hash_mem)
-		dm_pool_destroy(_hash_mem);
+	if (_wwid_mem)
+		dm_pool_destroy(_wwid_mem);
 
 	_minor_hash_tab = NULL;
 	_wwid_hash_tab = NULL;
-	_hash_mem = NULL;
+	_wwid_mem = NULL;
 }
 
 
diff --git a/test/shell/duplicate-pvs-multipath.sh b/test/shell/duplicate-pvs-multipath.sh
index a145e4afb..59c15b0d4 100644
--- a/test/shell/duplicate-pvs-multipath.sh
+++ b/test/shell/duplicate-pvs-multipath.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-test_description='udev rule and systemd unit run vgchange'
+test_description='duplicate pv detection of mpath components using wwid'
 
 SKIP_WITH_LVMPOLLD=1
 SKIP_WITH_LVMLOCKD=1
diff --git a/test/shell/multipath-config.sh b/test/shell/multipath-config.sh
new file mode 100644
index 000000000..ffb7d632a
--- /dev/null
+++ b/test/shell/multipath-config.sh
@@ -0,0 +1,171 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='using multipath blacklist'
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# FIXME: don't run this test by default because it destroys the
+# local multipath config, the timing of multipath/dm/lvm interactions
+# is fragile, and there's insufficient cleanup after a test fails.
+skip
+
+systemctl stop multipathd
+multipath -F || true
+rm /etc/multipath/wwids || true
+rmmod scsi_debug || true
+rm /etc/multipath/conf.d/lvmtest.conf || true
+
+modprobe --dry-run scsi_debug || skip
+multipath -l || skip
+multipath -l | grep scsi_debug && skip
+ls /etc/multipath/wwids && skip
+
+# Need to use /dev/mapper/mpath
+aux lvmconf 'devices/dir = "/dev"'
+aux lvmconf 'devices/scan = "/dev"'
+# Could set filter to $MP and the component /dev/sd devs
+aux lvmconf "devices/filter = [ \"a|.*|\" ]"
+aux lvmconf "devices/global_filter = [ \"a|.*|\" ]"
+
+modprobe scsi_debug dev_size_mb=16 num_tgts=1
+sleep 2
+
+# Get scsi device name created by scsi_debug.
+# SD = sdh
+# SD_DEV = /dev/sdh
+
+SD=$(grep -H scsi_debug /sys/block/sd*/device/model | cut -f4 -d /);
+echo $SD
+SD_DEV=/dev/$SD
+echo $SD_DEV
+
+# if multipath claimed SD, then io will fail
+#dd if=$SD_DEV of=/dev/null bs=4k count=1 iflag=direct
+#dd if=/dev/zero of=$SD_DEV bs=4k count=1 oflag=direct
+
+# check if multipathd claimed the scsi dev when it appears and create mp dm device
+sleep 2
+multipath -l
+# create the mp dm device
+multipath $SD_DEV
+
+# Get mpath device name created by multipath.
+# MP = mpatha
+# MP_DEV = /dev/maper/mpatha
+
+MP=$(multipath -l | grep scsi_debug | cut -f1 -d ' ')
+echo $MP
+MP_DEV=/dev/mapper/$MP
+echo $MP_DEV
+
+dd if=$MP_DEV of=/dev/null bs=4k count=1 iflag=direct
+dd if=/dev/zero of=$MP_DEV bs=4k count=1 oflag=direct
+
+# Get wwid for the mp and sd dev.
+WWID=$(multipath -l $MP_DEV | head -1 | awk '{print $2}' | tr -d ')' | tr -d '(')
+echo $WWID
+
+grep $WWID /etc/multipath/wwids
+
+pvcreate $MP_DEV
+vgcreate $vg1 $MP_DEV
+
+not pvs $SD_DEV
+pvs $MP_DEV
+
+# remove mpath dm device then check that SD_DEV is
+# filtered based on /etc/multipath/wwids instead of
+# based on sysfs holder
+multipath -f $MP
+sleep 2
+not pvs $SD_DEV
+multipath $SD_DEV
+sleep 2
+multipath -l | grep $SD
+
+#
+# Add the wwid to the blacklist, then restart multipath
+# so the sd dev should no longer be used by multipath,
+# but the sd dev wwid is still in /etc/multipath/wwids.
+#
+
+mkdir /etc/multipath/conf.d/ || true
+rm -f /etc/multipath/conf.d/lvmtest.conf
+
+cat <<EOF > "/etc/multipath/conf.d/lvmtest.conf"
+blacklist {
+	wwid $WWID
+}
+EOF
+
+cat /etc/multipath/conf.d/lvmtest.conf
+
+multipath -r
+sleep 2
+
+grep $WWID /etc/multipath/wwids
+
+multipath -l |tee out
+not grep $SD out
+not grep $MP out
+not grep $WWID out
+
+not pvs $MP_DEV
+pvs $SD_DEV
+vgs $vg1
+
+#
+# Add the wwid to the blacklist_exceptions, in addition
+# to the blacklist, then restart multipath so the
+# sd dev should again be used by multipath.
+#
+
+rm -f /etc/multipath/conf.d/lvmtest.conf
+
+cat <<EOF > "/etc/multipath/conf.d/lvmtest.conf"
+blacklist {
+wwid $WWID
+}
+blacklist_exceptions {
+wwid $WWID
+}
+EOF
+
+cat /etc/multipath/conf.d/lvmtest.conf
+
+multipath -r
+sleep 2
+
+grep $WWID /etc/multipath/wwids
+
+multipath -l |tee out
+grep $SD out
+grep $MP out
+grep $WWID out
+
+pvs $MP_DEV
+not pvs $SD_DEV
+vgs $vg1
+lvs $vg1
+
+sleep 2
+vgremove -ff $vg1
+sleep 2
+multipath -f $MP
+rm /etc/multipath/conf.d/lvmtest.conf
+rm /etc/multipath/wwids
+sleep 1
+rmmod scsi_debug

