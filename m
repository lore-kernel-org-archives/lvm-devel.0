From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 29 Jun 2015 12:33:17 +0000 (UTC)
Subject: master - conf: make time format configurable
Message-ID: <20150629123317.22E8860F39@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=125cd06698bc1c52b812faa1686988b92cc2e192
Commit:        125cd06698bc1c52b812faa1686988b92cc2e192
Parent:        6f793d34ca8993d1e70df58340d7c1897b368a09
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 25 16:13:07 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 29 14:30:35 2015 +0200

conf: make time format configurable

Make it possible to define format for time that is displayed.
The way the format is defined is equal to the way that is used
for strftime function, although not all formatting options as
used in strftime are available for LVM2 - the set is restricted
(e.g. we do not allow newline to be printed). The lvm.conf
comments contain the whole list that LVM2 accepts for time format
together with brief description (copied from strftime man page).

For example:
(defaults used - the format is the same as used before this patch)
$ lvs -o+time vg/lvol0 vg/lvol1
  LV    VG   Attr       LSize Time
  lvol0 vg   -wi-a----- 4.00m 2015-06-25 16:18:34 +0200
  lvol1 vg   -wi-a----- 4.00m 2015-06-29 09:17:11 +0200

(using 'time_format = "@%s"' in lvm.conf - number of seconds
since the Epoch)
$ lvs -o+time vg/lvol0 vg/lvol1
  LV    VG   Attr       LSize Time
  lvol0 vg   -wi-a----- 4.00m @1435241914
  lvol1 vg   -wi-a----- 4.00m @1435562231
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   73 ++++++++++++++++++++++++++++++++++++++++++
 lib/commands/toolcontext.c   |   52 ++++++++++++++++++++++++++++++
 lib/commands/toolcontext.h   |    2 +
 lib/config/config_settings.h |   73 ++++++++++++++++++++++++++++++++++++++++++
 lib/config/defaults.h        |    1 +
 lib/display/display.c        |    2 +-
 lib/metadata/lv.c            |    7 ++--
 lib/metadata/lv.h            |    2 +-
 lib/report/properties.c      |    2 +-
 lib/report/report.c          |    2 +-
 11 files changed, 209 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 813eb5e..9a7ebe1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.123 - 
 =================================
+  Add report/time_format lvm.conf option to define time format for report.
   Fix makefile shell compare == when building lvmetad lvmpolld (2.02.120).
   Add --type full to lvmconfig for full configuration tree view.
   Add undocumented environment variables to lvm man page. (2.02.119)
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 3433508..41b9702 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1411,6 +1411,79 @@ activation {
 	# value could not be determined).
 	# binary_values_as_numeric = 0
 
+	# Configuration option report/time_format.
+	# Set time format for fields reporting time values.
+	# Format specification is a string which may contain special character
+	# sequences and ordinary character sequences. Ordinary character sequences
+	# are copied verbatim. Each special character sequence is introduced by '%'
+	# character and such sequence is then substitued with a value as described below:
+	# %a     The abbreviated name of the day of the week according to the
+	#        current locale.
+	# %A     The full name of the day of the week according to the current locale.
+	# %b     The abbreviated month name according to the current locale.
+	# %B     The full month name according to the current locale.
+	# %c     The preferred date and time representation for the current locale. (alt E)
+	# %C     The century number (year/100) as a 2-digit integer. (alt E)
+	# %d     The day of the month as a decimal number (range 01 to 31). (alt O)
+	# %D     Equivalent to %m/%d/%y.  (For Americans only. Americans should
+	#        note that in other countries%d/%m/%y is rather common. This means
+	#        that in international context this format is ambiguous and should not
+	#        be used.
+	# %e     Like %d, the day of the month as a decimal number, but a leading zero
+	#        is replaced by a space. (alt O)
+	# %E     Modifier: use alternative local-dependent representation if available.
+	# %F     Equivalent to %Y-%m-%d (the ISO 8601 date format).
+	# %G     The ISO 8601 week-based year with century as adecimal number. The 4-digit
+	#        year corresponding to the ISO week number (see %V). This has the same
+	#        format and value as %Y, except that if the ISO week number belongs to
+	#        the previous or next year, that year is used instead.
+	# %g     Like %G, but without century, that is, with a 2-digit year (00-99).
+	# %h     Equivalent to %b.
+	# %H     The hour as a decimal number using a 24-hour clock (range 00 to 23). (alt O)
+	# %I     The hour as a decimal number using a 12-hour clock (range 01 to 12). (alt O)
+	# %j     The day of the year as a decimal number (range 001 to 366).
+	# %k     The hour (24-hour clock) as a decimal number (range 0 to 23);
+	#        single digits are preceded by a blank. (See also %H.)
+	# %l     The hour (12-hour clock) as a decimal number (range 1 to 12);
+	#        single digits are preceded by a blank. (See also %I.)
+	# %m     The month as a decimal number (range 01 to 12). (alt O)
+	# %M     The minute as a decimal number (range 00 to 59). (alt O)
+	# %O     Modifier: use alternative numeric symbols.
+	# %p     Either "AM" or "PM" according to the given time value,
+	#        or the corresponding strings for the current locale. Noon is
+	#        treated as "PM" and midnight as "AM".
+	# %P     Like %p but in lowercase: "am" or "pm" or a corresponding
+	#        string for the current locale.
+	# %r     The time in a.m. or p.m. notation. In the POSIX locale this is
+	#        equivalent to %I:%M:%S %p.
+	# %R     The time in 24-hour notation (%H:%M). For a version including
+	#        the seconds, see %T below.
+	# %s     The number of seconds since the Epoch, 1970-01-01 00:00:00 +0000 (UTC)
+	# %S     The second as a decimal number (range 00 to 60).
+	#        (The range is up to 60 to allow for occasional leap seconds.) (alt O)
+	# %t     A tab character.
+	# %T     The time in 24-hour notation (%H:%M:%S).
+	# %u     The day of the week as a decimal, range 1 to 7, Monday being 1.
+	#        See also %w. (alt O)
+	# %U     The week number of the current year as a decimal number,
+	#        range 00 to 53, starting with the first Sunday as the first
+	#        day of week 01. See also %V and %W. (alt O)
+	# %V     The ISO 8601 week number of the current year as a decimal number,
+	#        range 01 to 53, where week 1 is the first week that has at least 4 days
+	#        in the new year. See also %U and %W. (alt O)
+	# %w     The day of the week as a decimal, range 0 to 6, Sunday being 0.
+	#        See also %u. (alt O)
+	# %W     The week number of the current year as a decimal number, range 00 to 53,
+	#        starting with the first Monday as the first day of week 01. (alt O)
+	# %x     The preferred date representation for the current locale without the time. (alt E)
+	# %X     The preferred time representation for the current locale without the date. (alt E)
+	# %y     The year as a decimal number without a century (range 00 to 99). (alt E, alt O)
+	# %Y     The year as a decimal number including the century. (alt E)
+	# %z     The +hhmm or -hhmm numeric timezone (that is, the hour and minute
+	#        offset from UTC).%Z     The timezone name or abbreviation.
+	# %%    A literal '%' character.
+	# time_format = "%Y-%m-%d %T %z"
+
 	# Configuration option report/devtypes_sort.
 	# List of columns to sort by when reporting 'lvm devtypes' command.
 	# See 'lvm devtypes -o help' for the list of possible fields.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 47aa209..0d243f2 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -413,6 +413,57 @@ static int _check_config(struct cmd_context *cmd)
 	return 1;
 }
 
+static const char *_set_time_format(struct cmd_context *cmd)
+{
+	/* Compared to strftime, we do not allow "newline" character - the %n in format. */
+	static const char *allowed_format_chars = "aAbBcCdDeFGghHIjklmMpPrRsStTuUVwWxXyYzZ%";
+	static const char *allowed_alternative_format_chars_e = "cCxXyY";
+	static const char *allowed_alternative_format_chars_o = "deHImMSuUVwWy";
+	static const char *chars_to_check;
+	const char *tf = find_config_tree_str(cmd, report_time_format_CFG, NULL);
+	const char *p_fmt;
+	size_t i;
+	char c;
+
+	if (!*tf) {
+		log_error("Configured time format is empty string.");
+		goto bad;
+	} else {
+		p_fmt = tf;
+		while ((c = *p_fmt)) {
+			if (c == '%') {
+				c = *++p_fmt;
+				if (c == 'E') {
+					c = *++p_fmt;
+					chars_to_check = allowed_alternative_format_chars_e;
+				} else if (c == 'O') {
+					c = *++p_fmt;
+					chars_to_check = allowed_alternative_format_chars_o;
+				} else
+					chars_to_check = allowed_format_chars;
+
+				for (i = 0; chars_to_check[i]; i++) {
+					if (c == allowed_format_chars[i])
+						break;
+				}
+				if (!allowed_format_chars[i])
+					goto_bad;
+			}
+			else if (isprint(c))
+				p_fmt++;
+			else {
+				log_error("Configured time format contains non-printable characters.");
+				goto bad;
+			}
+		}
+	}
+
+	return tf;
+bad:
+	log_error("Incorrect time format specified. Using default time format instead.");
+	return DEFAULT_TIME_FORMAT;
+}
+
 int process_profilable_config(struct cmd_context *cmd)
 {
 	if (!(cmd->default_settings.unit_factor =
@@ -426,6 +477,7 @@ int process_profilable_config(struct cmd_context *cmd)
 	cmd->report_binary_values_as_numeric = find_config_tree_bool(cmd, report_binary_values_as_numeric_CFG, NULL);
 	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
 	cmd->report_list_item_separator = find_config_tree_str(cmd, report_list_item_separator_CFG, NULL);
+	cmd->time_format = _set_time_format(cmd);
 
 	return 1;
 }
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 66bea5f..46d83b3 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -95,6 +95,8 @@ struct cmd_context {
 	unsigned ignore_clustered_vgs:1;
 	unsigned threaded:1;		/* Set if running within a thread e.g. clvmd */
 
+	const char *time_format;
+
 	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
 	unsigned unknown_system_id:1;
 	unsigned include_foreign_vgs:1;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 2c5e2f8..ac68906 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1357,6 +1357,79 @@ cfg(report_binary_values_as_numeric_CFG, "binary_values_as_numeric", report_CFG_
 	"(not counting the 'unknown' value which denotes that the\n"
 	"value could not be determined).\n")
 
+cfg(report_time_format_CFG, "time_format", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_TIME_FORMAT, vsn(2, 2, 121), NULL, 0, NULL,
+        "Set time format for fields reporting time values.\n"
+	"Format specification is a string which may contain special character\n"
+	"sequences and ordinary character sequences. Ordinary character sequences\n"
+	"are copied verbatim. Each special character sequence is introduced by \'%\'\n"
+	"character and such sequence is then substitued with a value as described below:\n"
+	"\%a     The abbreviated name of the day of the week according to the\n"
+	"       current locale.\n"
+	"\%A     The full name of the day of the week according to the current locale.\n"
+	"\%b     The abbreviated month name according to the current locale.\n"
+	"\%B     The full month name according to the current locale.\n"
+	"\%c     The preferred date and time representation for the current locale. (alt E)\n"
+	"\%C     The century number (year/100) as a 2-digit integer. (alt E)\n"
+	"\%d     The day of the month as a decimal number (range 01 to 31). (alt O)\n"
+	"\%D     Equivalent to \%m/\%d/\%y.  (For Americans only. Americans should\n"
+	"       note that in other countries\%d/\%m/\%y is rather common. This means\n"
+	"       that in international context this format is ambiguous and should not\n"
+	"       be used.\n"
+	"\%e     Like \%d, the day of the month as a decimal number, but a leading zero\n"
+	"       is replaced by a space. (alt O)\n"
+	"\%E     Modifier: use alternative local-dependent representation if available.\n"
+	"\%F     Equivalent to \%Y-\%m-\%d (the ISO 8601 date format).\n"
+	"\%G     The ISO 8601 week-based year with century as adecimal number. The 4-digit\n"
+	"       year corresponding to the ISO week number (see \%V). This has the same\n"
+	"       format and value as \%Y, except that if the ISO week number belongs to\n"
+	"       the previous or next year, that year is used instead.\n"
+	"\%g     Like \%G, but without century, that is, with a 2-digit year (00-99).\n"
+	"\%h     Equivalent to \%b.\n"
+	"\%H     The hour as a decimal number using a 24-hour clock (range 00 to 23). (alt O)\n"
+	"\%I     The hour as a decimal number using a 12-hour clock (range 01 to 12). (alt O)\n"
+	"\%j     The day of the year as a decimal number (range 001 to 366).\n"
+	"\%k     The hour (24-hour clock) as a decimal number (range 0 to 23);\n"
+	"       single digits are preceded by a blank. (See also \%H.)\n"
+	"\%l     The hour (12-hour clock) as a decimal number (range 1 to 12);\n"
+	"       single digits are preceded by a blank. (See also \%I.)\n"
+	"\%m     The month as a decimal number (range 01 to 12). (alt O)\n"
+	"\%M     The minute as a decimal number (range 00 to 59). (alt O)\n"
+	"\%O     Modifier: use alternative numeric symbols.\n"
+	"\%p     Either \"AM\" or \"PM\" according to the given time value,\n"
+	"       or the corresponding strings for the current locale. Noon is\n"
+	"       treated as \"PM\" and midnight as \"AM\".\n"
+	"\%P     Like \%p but in lowercase: \"am\" or \"pm\" or a corresponding\n"
+	"       string for the current locale.\n"
+	"\%r     The time in a.m. or p.m. notation. In the POSIX locale this is\n"
+	"       equivalent to \%I:\%M:\%S \%p.\n"
+	"\%R     The time in 24-hour notation (\%H:\%M). For a version including\n"
+	"       the seconds, see \%T below.\n"
+	"\%s     The number of seconds since the Epoch, 1970-01-01 00:00:00 +0000 (UTC)\n"
+	"\%S     The second as a decimal number (range 00 to 60).\n"
+	"       (The range is up to 60 to allow for occasional leap seconds.) (alt O)\n"
+	"\%t     A tab character.\n"
+	"\%T     The time in 24-hour notation (\%H:\%M:\%S).\n"
+	"\%u     The day of the week as a decimal, range 1 to 7, Monday being 1.\n"
+	"       See also \%w. (alt O)\n"
+	"\%U     The week number of the current year as a decimal number,\n"
+	"       range 00 to 53, starting with the first Sunday as the first\n"
+	"       day of week 01. See also \%V and \%W. (alt O)\n"
+	"\%V     The ISO 8601 week number of the current year as a decimal number,\n"
+	"       range 01 to 53, where week 1 is the first week that has at least 4 days\n"
+	"       in the new year. See also \%U and \%W. (alt O)\n"
+	"\%w     The day of the week as a decimal, range 0 to 6, Sunday being 0.\n"
+	"       See also \%u. (alt O)\n"
+	"\%W     The week number of the current year as a decimal number, range 00 to 53,\n"
+	"       starting with the first Monday as the first day of week 01. (alt O)\n"
+	"\%x     The preferred date representation for the current locale without the time. (alt E)\n"
+	"\%X     The preferred time representation for the current locale without the date. (alt E)\n"
+	"\%y     The year as a decimal number without a century (range 00 to 99). (alt E, alt O)\n"
+	"\%Y     The year as a decimal number including the century. (alt E)\n"
+	"\%z     The +hhmm or -hhmm numeric timezone (that is, the hour and minute\n"
+	"       offset from UTC)."
+	"\%Z     The timezone name or abbreviation.\n"
+	"\%\%    A literal '\%' character.\n")
+
 cfg(report_devtypes_sort_CFG, "devtypes_sort", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DEVTYPES_SORT, vsn(2, 2, 101), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'lvm devtypes' command.\n"
 	"See 'lvm devtypes -o help' for the list of possible fields.\n")
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index d764ec9..3745639 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -197,6 +197,7 @@
 #define DEFAULT_REP_QUOTED 1
 #define DEFAULT_REP_SEPARATOR " "
 #define DEFAULT_REP_LIST_ITEM_SEPARATOR ","
+#define DEFAULT_TIME_FORMAT "%Y-%m-%d %T %z"
 
 #define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,metadata_percent,move_pv,mirror_log,copy_percent,convert_lv"
 #define DEFAULT_VGS_COLS "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
diff --git a/lib/display/display.c b/lib/display/display.c
index 8f075d9..059bc8f 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -489,7 +489,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 	log_print("LV UUID                %s", uuid);
 	log_print("LV Write Access        %s", access_str);
 	log_print("LV Creation host, time %s, %s",
-		  lv_host_dup(cmd->mem, lv), lv_time_dup(cmd->mem, lv));
+		  lv_host_dup(cmd->mem, lv), lv_time_dup(cmd->mem, lv, 1));
 
 	if (lv_is_origin(lv)) {
 		log_print("LV snapshot status     source of");
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9a99c8d..2a87edd 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -873,17 +873,16 @@ int lv_set_creation(struct logical_volume *lv,
 	return 1;
 }
 
-char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv)
+char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode)
 {
 	char buffer[50];
 	struct tm *local_tm;
 	time_t ts = (time_t)lv->timestamp;
+	const char *format = iso_mode ? DEFAULT_TIME_FORMAT : lv->vg->cmd->time_format;
 
 	if (!ts ||
 	    !(local_tm = localtime(&ts)) ||
-	    /* FIXME: make this lvm.conf configurable */
-	    !strftime(buffer, sizeof(buffer),
-		      "%Y-%m-%d %T %z", local_tm))
+	    !strftime(buffer, sizeof(buffer), format, local_tm))
 		buffer[0] = 0;
 
 	return dm_pool_strdup(mem, buffer);
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 4475085..f7bbb1e 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -91,7 +91,7 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
-char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode);
 char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_set_creation(struct logical_volume *lv,
 		    const char *hostname, uint64_t timestamp);
diff --git a/lib/report/properties.c b/lib/report/properties.c
index b0a91a7..5cd3c4d 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -342,7 +342,7 @@ GET_LV_NUM_PROPERTY_FN(metadata_percent, _metadata_percent(lv))
 #define _metadata_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_metadata_size, lv_metadata_size(lv) * SECTOR_SIZE)
 #define _lv_metadata_size_set prop_not_implemented_set
-GET_LV_STR_PROPERTY_FN(lv_time, lv_time_dup(lv->vg->vgmem, lv))
+GET_LV_STR_PROPERTY_FN(lv_time, lv_time_dup(lv->vg->vgmem, lv, 0))
 #define _lv_time_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_host, lv_host_dup(lv->vg->vgmem, lv))
 #define _lv_host_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index a107669..30b3767 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1474,7 +1474,7 @@ static int _lvtime_disp(struct dm_report *rh, struct dm_pool *mem,
 	char *repstr;
 	uint64_t *sortval;
 
-	if (!(repstr = lv_time_dup(mem, lv)) ||
+	if (!(repstr = lv_time_dup(mem, lv, 0)) ||
 	    !(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
 		log_error("Failed to allocate buffer for time.");
 		return 0;


