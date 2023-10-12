From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Thu, 12 Oct 2023 15:24:43 +0000
Subject: [Git][lvmteam/lvm2][main] 8 commits: Clean up group struct in _stats_create_group() error path
Message-ID: <65280fbb5953_2ca5348250cc@gitlab-sidekiq-low-urgency-cpu-bound-v2-77dd58995b-4gtms.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
eda99fc3 by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
Clean up group struct in _stats_create_group() error path

Fix a double free in the error path from _stats_create_group() by
clearing the group struct embedded in the dm_stats handle before
returning:

    device-mapper: message ioctl on  (253:0) failed: Invalid argument
    Could not create regions from file /var/tmp/File With Spaces.
    free(): double free detected in tcache 2
    Aborted (core dumped)

- - - - -
f0fd03b1 by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
dmstats: use correct value for precise in _stats_create_file()

- - - - -
ac41deee by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
Rename _stats_set_aux() argument

The aux_data argument of _stats_set_aux() is the user-defined data
to be stored with the stats region. Rename the argument to better
reflect this.

- - - - -
33931431 by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
Refactor _stats_parse_list_region()

Refactor the function that parses regions from @stats_list data to
separate the parsing of variable string data from the fixed parts
of the @stats_list response.

- - - - -
7d8981dd by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
dmstats: support group aliases with embedded whitespace

Creating a group with a name that contains whitespace causes an error in
the @stats_set_aux message:

device-mapper: message ioctl on  (253:0) failed: Invalid argument
Could not create regions from file /var/tmp/File With Spaces.

Fix this by quoting the group alias and backslash escaping any
embedded space characters.

- - - - -
9aa47f97 by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
Quote path value in --filemap debug messages

Improves readability of debugging output when file paths contain
whitespace.

- - - - -
995c7b50 by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
Add more dmstats integration tests

Add new tests for filemap, group/ungroup, histograms, precise timestamps
and userdata.

- - - - -
0ff027ae by Bryn M. Reeves at 2023-10-12T11:31:14+00:00
dmstats: only generate aux data separator if group tag is defined

Fix a bug in _stats_set_aux() that causes bogus data to appear
in the &#39;userdata&#39; field of stats reports when previously grouped
regions are ungrouped:

/var/tmp/File With Spaces: Created new group with 1 region(s) as group ID 0.

Removed group ID 0 on fedora-root

Name             GrpID RgID ObjType RgStart RgSize  #Areas ArSize  ProgID  UserData
fedora-root          -    0 region    6.39g 100.00m      1 100.00m dmstats #-
                                                                           ^^
This is the aux_data separator character followed by empty user data.
The _stats_set_aux() function should only emit the separator if
there is a valid group descriptor for the region.

- - - - -


11 changed files:

- libdm/dm-tools/dmfilemapd.c
- libdm/dm-tools/dmsetup.c
- libdm/libdm-stats.c
- + test/shell/dmstats-filemap.sh
- + test/shell/dmstats-group-ungroup-nouserdata.sh
- + test/shell/dmstats-group-ungroup-userdata.sh
- + test/shell/dmstats-group.sh
- + test/shell/dmstats-histogram.sh
- + test/shell/dmstats-precise.sh
- + test/shell/dmstats-ungroup.sh
- + test/shell/dmstats-userdata.sh


Changes:

=====================================
libdm/dm-tools/dmfilemapd.c
=====================================
@@ -826,7 +826,7 @@ int main(int argc, char **argv)
 	_setup_logging();
 
 	log_info("Starting dmfilemapd with fd=%d, group_id=" FMTu64 " "
-		 "mode=%s, path=%s", fm.fd, fm.group_id,
+		 "mode=%s, path=\"%s\"", fm.fd, fm.group_id,
 		 _mode_names[fm.mode], fm.path);
 
 	if (!_foreground && !_daemonise(&fm)) {


=====================================
libdm/dm-tools/dmsetup.c
=====================================
@@ -5451,7 +5451,7 @@ static int _stats_create_file(CMD_ARGS)
 	if (!strlen(program_id) && !_switches[FORCE_ARG])
 		program_id = DM_STATS_PROGRAM_ID;
 
-	precise = _int_args[PRECISE_ARG];
+	precise = _switches[PRECISE_ARG];
 	group = !_switches[NOGROUP_ARG];
 
 	mode = _stats_get_filemapd_mode();


=====================================
libdm/libdm-stats.c
=====================================
@@ -136,6 +136,36 @@ struct dm_stats {
 	uint64_t cur_area;
 };
 
+static char *_stats_escape_aux_data(const char *aux_data)
+{
+	size_t aux_data_len = strlen(aux_data);
+	char *escaped = dm_malloc((3 * aux_data_len + 1) * sizeof(char));
+	size_t index = 0;
+
+	if (!escaped) {
+		log_error("Could not allocate memory for escaped "
+			  "aux_data string.");
+		return NULL;
+	}
+
+	for (size_t i = 0; i < aux_data_len; i++) {
+		if (aux_data[i] == ' ') {
+			escaped[index++] = '\\';
+			escaped[index++] = ' ';
+		} else if (aux_data[i] == '\\') {
+			escaped[index++] = '\\';
+			escaped[index++] = '\\';
+		} else if (aux_data[i] == '\t') {
+			escaped[index++] = '\\';
+			escaped[index++] = '\t';
+		} else {
+			escaped[index++] = aux_data[i];
+		}
+	}
+	escaped[index] = '\0';
+	return escaped;
+}
+
 #define PROC_SELF_COMM "/proc/self/comm"
 static char *_program_id_from_proc(void)
 {
@@ -697,6 +727,8 @@ static void _check_group_regions_present(struct dm_stats *dms,
 #define DMS_GROUP_TAG_LEN (sizeof(DMS_GROUP_TAG) - 1)
 #define DMS_GROUP_SEP ':'
 #define DMS_AUX_SEP "#"
+#define DMS_AUX_SEP_CHAR '#'
+#define DMS_GROUP_QUOTE '"'
 
 static int _parse_aux_data_group(struct dm_stats *dms,
 				 struct dm_stats_region *region,
@@ -713,7 +745,8 @@ static int _parse_aux_data_group(struct dm_stats *dms,
 	if (!c)
 		return 1; /* no group is not an error */
 
-	alias = c + strlen(DMS_GROUP_TAG);
+	/* extract alias from quotes */
+	alias = c + strlen(DMS_GROUP_TAG) + 1;
 
 	c = strchr(c, DMS_GROUP_SEP);
 
@@ -722,8 +755,9 @@ static int _parse_aux_data_group(struct dm_stats *dms,
 		return 0;
 	}
 
-	/* terminate alias and advance to members */
-	*(c++) = '\0';
+	/* terminate alias and advance to members accounting for closing quote */
+	*(c - 1) = '\0';
+	c++;
 
 	log_debug("Read alias '%s' from aux_data", alias);
 
@@ -901,12 +935,68 @@ bad:
 	return 0;
 }
 
+static int _stats_parse_string_data(char *string_data, char **program_id,
+				    char **aux_data, char **stats_args)
+{
+	char *p, *next_gap, *empty_string = (char *)"";
+	size_t len;
+
+	/*
+	 * String data format:
+	 * <program_id> <aux_data> [precise_timestamps] [histogram:n1,n2,n3,..]
+	 */
+
+	/* Remove trailing whitespace */
+	len = strlen(string_data);
+	if (len > 0 && (string_data)[len - 1] == '\n') {
+		(string_data)[len - 1] = '\0';
+	}
+	p = strchr(string_data, ' ');
+	if (!p) {
+		*aux_data = *stats_args = empty_string;
+		return 1;
+	}
+
+	*p = '\0';
+	*program_id = string_data;
+
+	p++;
+	if (strstr(p, DMS_GROUP_TAG)) {
+		*aux_data = p;
+		/* Skip over the group tag */
+		next_gap = strchr(p, DMS_AUX_SEP_CHAR);
+		next_gap = strchr(next_gap, ' ');
+		if (next_gap) {
+			*(next_gap++) = '\0';
+			*stats_args = next_gap++;
+		} else
+			*stats_args = empty_string;
+	} else {
+		next_gap = strchr(p, ' ');
+		if (next_gap) {
+			*next_gap = '\0';
+			*aux_data = p;
+			*stats_args = next_gap + 1;
+		} else {
+			*aux_data = p;
+			*stats_args = empty_string;
+		}
+	}
+
+	if (!strncmp(*program_id, "-", 1))
+		*program_id = empty_string;
+
+	if (!strncmp(*aux_data, "-", 1))
+		*aux_data = empty_string;
+
+	return 1;
+}
+
 static int _stats_parse_list_region(struct dm_stats *dms,
 				    struct dm_stats_region *region, char *line)
 {
-	char *p = NULL, string_data[STATS_ROW_BUF_LEN];
-	char *program_id, *aux_data, *stats_args;
-	char *empty_string = (char *) "";
+	char string_data[STATS_ROW_BUF_LEN];
+	char *p, *program_id, *aux_data, *stats_args;
 	int r;
 
 	memset(string_data, 0, sizeof(string_data));
@@ -922,56 +1012,32 @@ static int _stats_parse_list_region(struct dm_stats *dms,
 		   &region->region_id, &region->start, &region->len,
 		   &region->step, string_data);
 
-	if (r != 5)
-		return_0;
-
-	/* program_id is guaranteed to be first. */
-	program_id = string_data;
-
-	/*
-	 * FIXME: support embedded '\ ' in string data:
-	 *   s/strchr/_find_unescaped_space()/
-	 */
-	if ((p = strchr(string_data, ' '))) {
-		/* terminate program_id string. */
-		*p = '\0';
-		if (!strncmp(program_id, "-", 1))
-			program_id = empty_string;
-		aux_data = p + 1;
-		if ((p = strchr(aux_data, ' '))) {
-			/* terminate aux_data string. */
-			*p = '\0';
-			stats_args = p + 1;
-		} else
-			stats_args = empty_string;
+	if (r != 5) {
+		return 0;
+	}
 
-		/* no aux_data? */
-		if (!strncmp(aux_data, "-", 1))
-			aux_data = empty_string;
-		else
-			/* remove trailing newline */
-			aux_data[strlen(aux_data) - 1] = '\0';
-	} else
-		aux_data = stats_args = empty_string;
+	if (!_stats_parse_string_data(string_data, &program_id, &aux_data, &stats_args)) {
+		return_0;
+	}
 
-	if (strstr(stats_args, PRECISE_ARG))
-		region->timescale = 1;
-	else
-		region->timescale = NSEC_PER_MSEC;
+	region->timescale = strstr(stats_args, PRECISE_ARG) ? 1 : NSEC_PER_MSEC;
 
-	if ((p = strstr(stats_args, HISTOGRAM_ARG))) {
-		if (!_stats_parse_histogram_spec(dms, region, p))
+	p = strstr(stats_args, HISTOGRAM_ARG);
+	if (p) {
+		if (!_stats_parse_histogram_spec(dms, region, p)) {
 			return_0;
-	} else
+		}
+	} else {
 		region->bounds = NULL;
+	}
 
-	/* clear aggregate cache */
 	region->histogram = NULL;
-
 	region->group_id = DM_STATS_GROUP_NOT_PRESENT;
 
-	if (!(region->program_id = dm_strdup(program_id)))
+	if (!(region->program_id = dm_strdup(program_id))) {
 		return_0;
+	}
+
 	if (!(region->aux_data = dm_strdup(aux_data))) {
 		dm_free(region->program_id);
 		return_0;
@@ -1844,7 +1910,7 @@ static char *_build_group_tag(struct dm_stats *dms, uint64_t group_id)
 		return_0;
 
 	buflen += DMS_GROUP_TAG_LEN;
-	buflen += 1 + (alias ? strlen(alias) : 0); /* 'alias:' */
+	buflen += 1 + (alias ? strlen(alias) + 2 : 0); /* 'alias:' */
 
 	buf = aux_string = dm_malloc(buflen);
 	if (!buf) {
@@ -1858,7 +1924,11 @@ static char *_build_group_tag(struct dm_stats *dms, uint64_t group_id)
 	buf += DMS_GROUP_TAG_LEN;
 	buflen -= DMS_GROUP_TAG_LEN;
 
-	r = dm_snprintf(buf, buflen, "%s%c", alias ? alias : "", DMS_GROUP_SEP);
+	if (alias)
+		r = dm_snprintf(buf, buflen, "\"%s\"%c", alias, DMS_GROUP_SEP);
+	else
+		r = dm_snprintf(buf, buflen, "%c", DMS_GROUP_SEP);
+
 	if (r < 0)
 		goto_bad;
 
@@ -1882,9 +1952,9 @@ bad:
  * generated from the current group table and included in the message.
  */
 static int _stats_set_aux(struct dm_stats *dms,
-			  uint64_t region_id, const char *aux_data)
+			  uint64_t region_id, const char *user_data)
 {
-	const char *group_tag = NULL;
+	char *group_tag = NULL, *group_tag_escaped = NULL;
 	struct dm_task *dmt = NULL;
 	char msg[STATS_MSG_BUF_LEN];
 
@@ -1896,12 +1966,15 @@ static int _stats_set_aux(struct dm_stats *dms,
 				  "region ID " FMTu64, region_id);
 			goto bad;
 		}
+		group_tag_escaped = _stats_escape_aux_data(group_tag);
+		if (!group_tag_escaped)
+			goto bad;
 	}
 
 	if (dm_snprintf(msg, sizeof(msg), "@stats_set_aux " FMTu64 " %s%s%s ",
-			region_id, (group_tag) ? group_tag : "",
-			(group_tag) ? DMS_AUX_SEP : "",
-			(strlen(aux_data)) ? aux_data : "-") < 0) {
+			region_id, (group_tag_escaped) ? group_tag_escaped : "",
+			(group_tag_escaped) ? DMS_AUX_SEP : "",
+			(strlen(user_data)) ? user_data : "-") < 0) {
 		log_error("Could not prepare @stats_set_aux message");
 		goto bad;
 	}
@@ -1909,7 +1982,8 @@ static int _stats_set_aux(struct dm_stats *dms,
 	if (!(dmt = _stats_send_message(dms, msg)))
 		goto_bad;
 
-	dm_free((char *) group_tag);
+	dm_free(group_tag);
+	dm_free(group_tag_escaped);
 
 	/* no response to a @stats_set_aux message */
 	dm_task_destroy(dmt);
@@ -1934,6 +2008,7 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	const char *err_fmt = "Could not prepare @stats_create %s.";
 	const char *precise_str = PRECISE_ARG;
 	const char *resp, *opt_args = NULL;
+	char *aux_data_escaped = NULL;
 	struct dm_task *dmt = NULL;
 	int r = 0, nr_opt = 0;
 
@@ -1964,6 +2039,10 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	else
 		hist_arg = "";
 
+	aux_data_escaped = _stats_escape_aux_data(aux_data);
+	if (!aux_data_escaped)
+		return_0;
+
 	if (nr_opt) {
 		if ((dm_asprintf((char **)&opt_args, "%d %s %s%s", nr_opt,
 				 precise_str,
@@ -2007,6 +2086,7 @@ out:
 	if (dmt)
 		dm_task_destroy(dmt);
 	dm_free((void *) opt_args);
+	dm_free(aux_data_escaped);
 
 	return r;
 }
@@ -3908,9 +3988,14 @@ static int _stats_create_group(struct dm_stats *dms, dm_bitset_t regions,
 
 	/* force an update of the group tag stored in aux_data */
 	if (!_stats_set_aux(dms, *group_id, dms->regions[*group_id].aux_data))
-		return 0;
+		goto bad;
 
 	return 1;
+bad:
+	group->group_id = DM_STATS_GROUP_NOT_PRESENT;
+	group->regions = NULL;
+	dm_free((char *) group->alias);
+	return 0;
 }
 
 static int _stats_group_check_overlap(const struct dm_stats *dms,
@@ -5029,7 +5114,7 @@ int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
 	/* terminate args[argc] */
 	args[argc] = NULL;
 
-	log_very_verbose("Spawning daemon as '%s %d " FMTu64 " %s %s %u %u'",
+	log_very_verbose("Spawning daemon as '%s %d " FMTu64 " \"%s\" %s %u %u'",
 			 *args, fd, group_id, path, mode_str,
 			 foreground, verbose);
 


=====================================
test/shell/dmstats-filemap.sh
=====================================
@@ -0,0 +1,79 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# Don't attempt to test stats with driver < 4.33.00
+aux driver_at_least 4 33 || skip
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 1 2048
+
+mount_dir="mnt"
+hist_bounds="10ms,20ms,30ms"
+file_size="100m"
+
+test ! -d "$mount_dir" && mkdir "$mount_dir"
+
+cleanup_mounted_and_teardown()
+{
+	umount "$mount_dir" 2>/dev/null || true
+	aux teardown
+}
+
+trap 'cleanup_mounted_and_teardown' EXIT
+
+mkfs.xfs "$dev1"
+mount "$dev1" "$mount_dir"
+
+test_filemap()
+{
+	local map_file="$1"
+	local use_precise="$2"
+	local use_bounds="$3"
+	if [[ $use_precise == 1 ]]; then
+		precise="--precise"
+	else
+		precise=""
+	fi
+	if [[ $use_bounds == 1 ]]; then
+		bounds="--bounds $hist_bounds"
+	else
+		bounds=""
+	fi
+	fallocate -l "$file_size" "$mount_dir/$map_file"
+	dmstats create ${precise} ${bounds} --filemap "$mount_dir/$map_file"
+	dmstats list -ostats_name,precise |& tee out
+	grep "$map_file" out
+	if [[ $use_precise == 1 ]]; then
+		grep "1" out
+	fi
+	if [[ $use_bounds == 1 ]]; then
+		dmstats list -ostats_name,hist_bounds |& tee out
+		grep "$hist_bounds" out
+	fi
+	dmstats delete --allregions --alldevices
+	rm -f "$mount_dir/$map_file"
+}
+
+for file in "filenospace" "File With Spaces" "$(echo -ne 'file\twith\ttabs')"; do
+	for precise in 0 1; do
+		for bounds in 0 1; do
+			test_filemap "$file" "$precise" "$bounds"
+		done
+	done
+done
+
+sleep .5


=====================================
test/shell/dmstats-group-ungroup-nouserdata.sh
=====================================
@@ -0,0 +1,41 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# Don't attempt to test stats with driver < 4.33.00
+aux driver_at_least 4 33 || skip
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 1
+
+GROUP_NAME="group0"
+BAD_USERDATA="#-"
+
+# Create a region and make it part of a group with an alias
+dmstats create "$dev1"
+dmstats group --alias "$GROUP_NAME" --regions 0 "$dev1"
+dmstats list -ostats_name |& tee out
+grep "$GROUP_NAME" out
+
+# Ungroup the regions then remove them
+dmstats ungroup --groupid 0 "$dev1"
+
+# Verify userdata does not contain '#-'
+dmstats list -ouserdata |& tee out
+not grep "$BAD_USERDATA" out
+
+# Clean up
+dmstats delete --allregions "$dev1"


=====================================
test/shell/dmstats-group-ungroup-userdata.sh
=====================================
@@ -0,0 +1,43 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# Don't attempt to test stats with driver < 4.33.00
+aux driver_at_least 4 33 || skip
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 1
+
+GROUP_NAME="group0"
+USERDATA="foo"
+
+# Create a region and make it part of a group with an alias
+dmstats create "$dev1" --userdata "$USERDATA"
+dmstats group --alias "$GROUP_NAME" --regions 0 "$dev1"
+dmstats list -ostats_name |& tee out
+grep "$GROUP_NAME" out
+dmstats list -ouserdata |& tee out
+grep "$USERDATA" out
+
+# Ungroup the regions then remove them
+dmstats ungroup --groupid 0 "$dev1"
+
+# Verify userdata is still valid
+dmstats list -ouserdata |& tee out
+grep "$USERDATA" out
+
+# Clean up
+dmstats delete --allregions "$dev1"


=====================================
test/shell/dmstats-group.sh
=====================================
@@ -0,0 +1,34 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# Don't attempt to test stats with driver < 4.33.00
+aux driver_at_least 4 33 || skip
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 1
+
+GROUP_NAME="group0"
+
+# Create a region and make it part of a group with an alias
+dmstats create "$dev1"
+dmstats group --alias "$GROUP_NAME" --regions 0 "$dev1"
+dmstats list -ostats_name |& tee out
+grep "$GROUP_NAME" out
+
+# Remove the group and its regions
+dmstats delete --groupid 0 "$dev1"
+


=====================================
test/shell/dmstats-histogram.sh
=====================================
@@ -0,0 +1,30 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# Don't attempt to test stats with driver < 4.33.00
+aux driver_at_least 4 33 || skip
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 1
+
+HIST_BOUNDS="10ms,20ms,30ms"
+
+# Create a region with a histogram and verify it in the list output
+dmstats create --bounds "$HIST_BOUNDS" "$dev1"
+dmstats list -ostats_name,hist_bounds |& tee out
+grep "$HIST_BOUNDS" out
+


=====================================
test/shell/dmstats-precise.sh
=====================================
@@ -0,0 +1,28 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# Don't attempt to test stats with driver < 4.33.00
+aux driver_at_least 4 33 || skip
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 1
+
+# Create a region with precise_timestamps and verify it in the list output
+dmstats create --precise "$dev1"
+dmstats list -oprecise |& tee out
+grep "1" out
+


=====================================
test/shell/dmstats-ungroup.sh
=====================================
@@ -0,0 +1,35 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# Don't attempt to test stats with driver < 4.33.00
+aux driver_at_least 4 33 || skip
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 1
+
+GROUP_NAME="group0"
+
+# Create a region and make it part of a group with an alias
+dmstats create "$dev1"
+dmstats group --alias "$GROUP_NAME" --regions 0 "$dev1"
+dmstats list -ostats_name |& tee out
+grep "$GROUP_NAME" out
+
+# Ungroup the regions then remove them
+dmstats ungroup --groupid 0 "$dev1"
+dmstats delete --allregions "$dev1"
+


=====================================
test/shell/dmstats-userdata.sh
=====================================
@@ -0,0 +1,31 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# Don't attempt to test stats with driver < 4.33.00
+aux driver_at_least 4 33 || skip
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 1
+
+USERDATA="aword"
+
+# Create dmstats region with userdata and verify it is reported
+# in list output
+dmstats create --userdata "$USERDATA" "$dev1"
+dmstats list -ouserdata |& tee out
+grep "$USERDATA" out
+



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/25ef7a7b1a876f491bd361369423d7309358f6c1...0ff027ae2c40066e2dd49cb4a377884d7e10dcf2

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/25ef7a7b1a876f491bd361369423d7309358f6c1...0ff027ae2c40066e2dd49cb4a377884d7e10dcf2
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231012/d4c516ee/attachment-0001.htm>
