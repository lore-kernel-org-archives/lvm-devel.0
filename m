From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  3 Jul 2015 09:32:39 +0000 (UTC)
Subject: master - report: select: add handler to recognize fuzzy time specification
Message-ID: <20150703093239.4FA1560976@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9cee94372a7e45b6a40478ec17de1c142ed268d4
Commit:        9cee94372a7e45b6a40478ec17de1c142ed268d4
Parent:        3b1422c45c6c782f5134e74439ccdd6766085d4c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 3 10:43:07 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 3 10:51:31 2015 +0200

report: select: add handler to recognize fuzzy time specification

Recognize date and time specification within selection criteria
that is formulated in a more free-form way besides to the original
basic YYYY-MM-DD HH:MM format that libdevmapper supports.

Currently, this free-form format is recognized for lv_time field.

Users are able to use expressions from this set:
  - weekday names ("Sunday" - "Saturday" or abbreviated as "Sun" - "Sat")
  - labels for points in time ("noon", "midnight")
  - labels for a day relative to current day ("today", "yesterday")
  - points back in time with relative offset from today (N is a number)
    ( "N" "seconds"/"minutes"/"hours"/"days"/"weeks"/"years" "ago")
    ( "N" "secs"/"mins"/"hrs" ... "ago")
    ( "N" "s"/"m"/"h" ... "ago")
  - time specification either in hh:mm:ss format or with AM/PM suffixes
  - month names ("January" - "December" or abbreviated as "Jan" - "Dec")

For example:

$ date
Fri Jul  3 10:11:13 CEST 2015

$ lvmconfig --type full report/time_format
time_format="%a %Y-%m-%d %T %z %Z [%s]"

$ lvs
  LV    VG     Time
  lvol0 vg     Fri 2014-08-22 21:25:41 +0200 CEST [1408735541]
  lvol2 vg     Sun 2015-04-26 14:52:20 +0200 CEST [1430052740]
  root  fedora Wed 2015-05-27 08:09:21 +0200 CEST [1432706961]
  swap  fedora Wed 2015-05-27 08:09:21 +0200 CEST [1432706961]
  lvol1 vg     Tue 2015-06-30 03:25:43 +0200 CEST [1435627543]
  lvol3 vg     Tue 2015-06-30 14:52:23 +0200 CEST [1435668743]
  lvol6 vg     Wed 2015-07-01 13:35:56 +0200 CEST [1435750556]
  lvol4 vg     Thu 2015-07-02 12:12:02 +0200 CEST [1435831922]
  lvol5 vg     Thu 2015-07-02 14:30:32 +0200 CEST [1435840232]

$ lvs -S 'time=yesterday'
  LV    VG   Time
  lvol4 vg   Thu 2015-07-02 12:12:02 +0200 CEST [1435831922]
  lvol5 vg   Thu 2015-07-02 14:30:32 +0200 CEST [1435840232]

$ lvs -S 'time since "June 30"'
  LV    VG   Time
  lvol1 vg   Tue 2015-06-30 03:25:43 +0200 CEST [1435627543]
  lvol3 vg   Tue 2015-06-30 14:52:23 +0200 CEST [1435668743]
  lvol6 vg   Wed 2015-07-01 13:35:56 +0200 CEST [1435750556]
  lvol4 vg   Thu 2015-07-02 12:12:02 +0200 CEST [1435831922]
  lvol5 vg   Thu 2015-07-02 14:30:32 +0200 CEST [1435840232]

$ lvs -S 'time since "noon June 30"'
  LV    VG   Time
  lvol3 vg   Tue 2015-06-30 14:52:23 +0200 CEST [1435668743]
  lvol6 vg   Wed 2015-07-01 13:35:56 +0200 CEST [1435750556]
  lvol4 vg   Thu 2015-07-02 12:12:02 +0200 CEST [1435831922]
  lvol5 vg   Thu 2015-07-02 14:30:32 +0200 CEST [1435840232]

$ lvs -S 'time since "2 July 9AM"'
  LV    VG   Time
  lvol4 vg   Thu 2015-07-02 12:12:02 +0200 CEST [1435831922]
  lvol5 vg   Thu 2015-07-02 14:30:32 +0200 CEST [1435840232]

$ lvs -S 'time since "2 July 1PM"'
  LV    VG   Time
  lvol5 vg   Thu 2015-07-02 14:30:32 +0200 CEST [1435840232]

...and so on.
---
 WHATS_NEW            |    1 +
 lib/report/report.c  | 1034 ++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/report/values.h  |    1 +
 libdm/libdm-report.c |    6 +-
 4 files changed, 1040 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6c822c4..6a33e6d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.124 -
 =================================
+  Recognize free-form date/time values for lv_time field in selection criteria.
   Fix regression in select to match string fields if using synonyms (2.02.123).
   Fix regression when printing more lv names via display_lvname (2.02.122).
   Add missing error logging to unlock_vg and sync_local_dev_names callers.
diff --git a/lib/report/report.c b/lib/report/report.c
index 4d1b8eb..80d189a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -27,6 +27,7 @@
 
 #include <stddef.h> /* offsetof() */
 #include <float.h> /* DBL_MAX */
+#include <time.h>
 
 struct lvm_report_object {
 	struct volume_group *vg;
@@ -64,6 +65,1039 @@ static const double _siz_max = DBL_MAX;
  */
 static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 
+typedef enum {
+	/* top-level identification */
+	TIME_NULL,
+	TIME_NUM,
+	TIME_STR,
+
+	/* direct numeric value */
+	TIME_NUM__START,
+	TIME_NUM_MULTIPLIER,
+	TIME_NUM_MULTIPLIER_NEGATIVE,
+	TIME_NUM_DAY,
+	TIME_NUM_YEAR,
+	TIME_NUM__END,
+
+	/* direct string value */
+	TIME_STR_TIMEZONE,
+
+	/* time frame strings */
+	TIME_FRAME__START,
+	TIME_FRAME_AGO,
+	TIME_FRAME__END,
+
+	/* labels for dates */
+	TIME_LABEL_DATE__START,
+
+	TIME_LABEL_DATE_TODAY,
+	TIME_LABEL_DATE_YESTERDAY,
+
+	/* weekday name strings */
+	TIME_WEEKDAY__START,
+	TIME_WEEKDAY_SUNDAY,
+	TIME_WEEKDAY_MONDAY,
+	TIME_WEEKDAY_TUESDAY,
+	TIME_WEEKDAY_WEDNESDAY,
+	TIME_WEEKDAY_THURSDAY,
+	TIME_WEEKDAY_FRIDAY,
+	TIME_WEEKDAY_SATURDAY,
+	TIME_WEEKDAY__END,
+
+	TIME_LABEL_DATE__END,
+
+	/* labels for times */
+	TIME_LABEL_TIME__START,
+	TIME_LABEL_TIME_NOON,
+	TIME_LABEL_TIME_MIDNIGHT,
+	TIME_LABEL_TIME__END,
+
+	/* time unit strings */
+	TIME_UNIT__START,
+	TIME_UNIT_SECOND,
+	TIME_UNIT_SECOND_REL,
+	TIME_UNIT_MINUTE,
+	TIME_UNIT_MINUTE_REL,
+	TIME_UNIT_HOUR,
+	TIME_UNIT_HOUR_REL,
+	TIME_UNIT_AM,
+	TIME_UNIT_PM,
+	TIME_UNIT_DAY,
+	TIME_UNIT_WEEK,
+	TIME_UNIT_MONTH,
+	TIME_UNIT_YEAR,
+	TIME_UNIT_TZ_MINUTE,
+	TIME_UNIT_TZ_HOUR,
+	TIME_UNIT__END,
+
+	/* month name strings */
+	TIME_MONTH__START,
+	TIME_MONTH_JANUARY,
+	TIME_MONTH_FEBRUARY,
+	TIME_MONTH_MARCH,
+	TIME_MONTH_APRIL,
+	TIME_MONTH_MAY,
+	TIME_MONTH_JUNE,
+	TIME_MONTH_JULY,
+	TIME_MONTH_AUGUST,
+	TIME_MONTH_SEPTEMBER,
+	TIME_MONTH_OCTOBER,
+	TIME_MONTH_NOVEMBER,
+	TIME_MONTH_DECEMBER,
+	TIME_MONTH__END,
+} time_id_t;
+
+#define TIME_PROP_DATE 0x00000001 /* date-related */
+#define TIME_PROP_TIME 0x00000002 /* time-related */
+#define TIME_PROP_ABS  0x00000004 /* absolute value */
+#define TIME_PROP_REL  0x00000008 /* relative value */
+
+struct time_prop {
+	time_id_t id;
+	uint32_t prop_flags;
+	time_id_t granularity;
+};
+
+#define ADD_TIME_PROP(id, flags, granularity) [id] = {id, flags, granularity},
+
+static const struct time_prop _time_props[] = {
+	ADD_TIME_PROP(TIME_NULL,                    0,							TIME_NULL)
+	ADD_TIME_PROP(TIME_NUM,                     0,							TIME_NULL)
+	ADD_TIME_PROP(TIME_STR,                     0,							TIME_NULL)
+
+	ADD_TIME_PROP(TIME_NUM_MULTIPLIER,          0,							TIME_NULL)
+	ADD_TIME_PROP(TIME_NUM_MULTIPLIER_NEGATIVE, 0,							TIME_NULL)
+	ADD_TIME_PROP(TIME_NUM_DAY,                 TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_DAY)
+	ADD_TIME_PROP(TIME_NUM_YEAR,                TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_YEAR)
+
+	ADD_TIME_PROP(TIME_STR_TIMEZONE,            TIME_PROP_TIME | TIME_PROP_ABS,			TIME_NULL)
+
+	ADD_TIME_PROP(TIME_FRAME_AGO,               TIME_PROP_DATE | TIME_PROP_TIME | TIME_PROP_REL,	TIME_NULL)
+
+	ADD_TIME_PROP(TIME_LABEL_DATE_TODAY,        TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_DAY)
+	ADD_TIME_PROP(TIME_LABEL_DATE_YESTERDAY,    TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_DAY)
+	ADD_TIME_PROP(TIME_WEEKDAY_SUNDAY,          TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_DAY)
+	ADD_TIME_PROP(TIME_WEEKDAY_MONDAY,          TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_DAY)
+	ADD_TIME_PROP(TIME_WEEKDAY_TUESDAY,         TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_DAY)
+	ADD_TIME_PROP(TIME_WEEKDAY_WEDNESDAY,       TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_DAY)
+	ADD_TIME_PROP(TIME_WEEKDAY_THURSDAY,        TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_DAY)
+	ADD_TIME_PROP(TIME_WEEKDAY_FRIDAY,          TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_DAY)
+	ADD_TIME_PROP(TIME_WEEKDAY_SATURDAY,        TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_DAY)
+
+	ADD_TIME_PROP(TIME_LABEL_TIME_NOON,         TIME_PROP_TIME | TIME_PROP_ABS,			TIME_UNIT_SECOND)
+	ADD_TIME_PROP(TIME_LABEL_TIME_MIDNIGHT,     TIME_PROP_TIME | TIME_PROP_ABS,			TIME_UNIT_SECOND)
+
+	ADD_TIME_PROP(TIME_UNIT_SECOND,             TIME_PROP_TIME | TIME_PROP_ABS,			TIME_UNIT_SECOND)
+	ADD_TIME_PROP(TIME_UNIT_SECOND_REL,         TIME_PROP_TIME | TIME_PROP_REL,			TIME_UNIT_SECOND)
+	ADD_TIME_PROP(TIME_UNIT_MINUTE,             TIME_PROP_TIME | TIME_PROP_ABS,			TIME_UNIT_MINUTE)
+	ADD_TIME_PROP(TIME_UNIT_MINUTE_REL,         TIME_PROP_TIME | TIME_PROP_REL,			TIME_UNIT_MINUTE)
+	ADD_TIME_PROP(TIME_UNIT_HOUR,               TIME_PROP_TIME | TIME_PROP_ABS,			TIME_UNIT_HOUR)
+	ADD_TIME_PROP(TIME_UNIT_HOUR_REL,           TIME_PROP_TIME | TIME_PROP_REL,			TIME_UNIT_HOUR)
+	ADD_TIME_PROP(TIME_UNIT_AM,                 TIME_PROP_TIME | TIME_PROP_ABS,			TIME_UNIT_HOUR)
+	ADD_TIME_PROP(TIME_UNIT_PM,                 TIME_PROP_TIME | TIME_PROP_ABS,			TIME_UNIT_HOUR)
+	ADD_TIME_PROP(TIME_UNIT_DAY,                TIME_PROP_DATE | TIME_PROP_REL,			TIME_UNIT_DAY)
+	ADD_TIME_PROP(TIME_UNIT_WEEK,               TIME_PROP_DATE | TIME_PROP_REL,			TIME_UNIT_WEEK)
+	ADD_TIME_PROP(TIME_UNIT_MONTH,              TIME_PROP_DATE | TIME_PROP_REL,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_UNIT_YEAR,               TIME_PROP_DATE | TIME_PROP_REL,			TIME_UNIT_YEAR)
+	ADD_TIME_PROP(TIME_UNIT_TZ_MINUTE,          TIME_PROP_TIME | TIME_PROP_ABS,			TIME_NULL)
+	ADD_TIME_PROP(TIME_UNIT_TZ_HOUR,            TIME_PROP_TIME | TIME_PROP_ABS,			TIME_NULL)
+
+	ADD_TIME_PROP(TIME_MONTH_JANUARY,           TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_FEBRUARY,          TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_MARCH,             TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_APRIL,             TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_MAY,               TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_JUNE,              TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_JULY,              TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_AUGUST,            TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_SEPTEMBER,         TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_OCTOBER,           TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_NOVEMBER,          TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+	ADD_TIME_PROP(TIME_MONTH_DECEMBER,          TIME_PROP_DATE | TIME_PROP_ABS,			TIME_UNIT_MONTH)
+};
+
+#define TIME_REG_PLURAL_S  0x00000001 /* also recognize plural form with "s" suffix */
+
+struct time_reg {
+	const char *name;
+	const struct time_prop *prop;
+	uint32_t reg_flags;
+};
+
+#define TIME_PROP(id) (_time_props + id)
+
+static const struct time_reg _time_reg[] = {
+	/*
+	 * Group of tokens representing time frame and used
+	 * with relative date/time to specify different flavours
+	 * of relativity.
+	 */
+	{"ago",       TIME_PROP(TIME_FRAME_AGO),            0},
+
+	/*
+	 * Group of tokens labeling some date and used
+	 * instead of direct absolute specification.
+	 */
+	{"today",     TIME_PROP(TIME_LABEL_DATE_TODAY),     0}, /* 0:00 - 23:59:59 for current date */
+	{"yesterday", TIME_PROP(TIME_LABEL_DATE_YESTERDAY), 0}, /* 0:00 - 23:59:59 for current date minus 1 day*/
+
+	/*
+	 * Group of tokens labeling some date - weekday
+	 * names used to build up date.
+	 */
+	{"Sunday",    TIME_PROP(TIME_WEEKDAY_SUNDAY),       TIME_REG_PLURAL_S},
+	{"Sun",       TIME_PROP(TIME_WEEKDAY_SUNDAY),       0},
+	{"Monday",    TIME_PROP(TIME_WEEKDAY_MONDAY),       TIME_REG_PLURAL_S},
+	{"Mon",       TIME_PROP(TIME_WEEKDAY_MONDAY),       0},
+	{"Tuesday",   TIME_PROP(TIME_WEEKDAY_TUESDAY),      TIME_REG_PLURAL_S},
+	{"Tue",       TIME_PROP(TIME_WEEKDAY_TUESDAY),      0},
+	{"Wednesday", TIME_PROP(TIME_WEEKDAY_WEDNESDAY),    TIME_REG_PLURAL_S},
+	{"Wed",       TIME_PROP(TIME_WEEKDAY_WEDNESDAY),    0},
+	{"Thursday",  TIME_PROP(TIME_WEEKDAY_THURSDAY),     TIME_REG_PLURAL_S},
+	{"Thu",       TIME_PROP(TIME_WEEKDAY_THURSDAY),     0},
+	{"Friday",    TIME_PROP(TIME_WEEKDAY_FRIDAY),       TIME_REG_PLURAL_S},
+	{"Fri",       TIME_PROP(TIME_WEEKDAY_FRIDAY),       0},
+	{"Saturday",  TIME_PROP(TIME_WEEKDAY_SATURDAY),     TIME_REG_PLURAL_S},
+	{"Sat",       TIME_PROP(TIME_WEEKDAY_SATURDAY),     0},
+
+	/*
+	 * Group of tokens labeling some time and used
+	 * instead of direct absolute specification.
+	 */
+	{"noon",      TIME_PROP(TIME_LABEL_TIME_NOON),      TIME_REG_PLURAL_S}, /* 12:00:00 */
+	{"midnight",  TIME_PROP(TIME_LABEL_TIME_MIDNIGHT),  TIME_REG_PLURAL_S}, /* 00:00:00 */
+
+	/*
+	 * Group of tokens used to build up time. Most of these
+	 * are used either as relative or absolute time units.
+	 * The absolute ones are always used with TIME_FRAME_*
+	 * token, otherwise the unit is relative.
+	 */
+	{"second",    TIME_PROP(TIME_UNIT_SECOND),          TIME_REG_PLURAL_S},
+	{"sec",       TIME_PROP(TIME_UNIT_SECOND),          TIME_REG_PLURAL_S},
+	{"s",         TIME_PROP(TIME_UNIT_SECOND),          0},
+	{"minute",    TIME_PROP(TIME_UNIT_MINUTE),          TIME_REG_PLURAL_S},
+	{"min",       TIME_PROP(TIME_UNIT_MINUTE),          TIME_REG_PLURAL_S},
+	{"m",         TIME_PROP(TIME_UNIT_MINUTE),          0},
+	{"hour",      TIME_PROP(TIME_UNIT_HOUR),            TIME_REG_PLURAL_S},
+	{"hr",        TIME_PROP(TIME_UNIT_HOUR),            TIME_REG_PLURAL_S},
+	{"h",         TIME_PROP(TIME_UNIT_HOUR),            0},
+	{"AM",        TIME_PROP(TIME_UNIT_AM),              0},
+	{"PM",        TIME_PROP(TIME_UNIT_PM),              0},
+
+	/*
+	 * Group of tokens used to build up date.
+	 * These are all relative ones.
+	 */
+	{"day",       TIME_PROP(TIME_UNIT_DAY),             TIME_REG_PLURAL_S},
+	{"week",      TIME_PROP(TIME_UNIT_WEEK),            TIME_REG_PLURAL_S},
+	{"month",     TIME_PROP(TIME_UNIT_MONTH),           TIME_REG_PLURAL_S},
+	{"year",      TIME_PROP(TIME_UNIT_YEAR),            TIME_REG_PLURAL_S},
+	{"yr",        TIME_PROP(TIME_UNIT_YEAR),            TIME_REG_PLURAL_S},
+
+	/*
+	 * Group of tokes used to build up date.
+	 * These are all absolute.
+	 */
+	{"January",   TIME_PROP(TIME_MONTH_JANUARY),        0},
+	{"Jan",       TIME_PROP(TIME_MONTH_JANUARY),        0},
+	{"February",  TIME_PROP(TIME_MONTH_FEBRUARY),       0},
+	{"Feb",       TIME_PROP(TIME_MONTH_FEBRUARY),       0},
+	{"March",     TIME_PROP(TIME_MONTH_MARCH),          0},
+	{"Mar",       TIME_PROP(TIME_MONTH_MARCH),          0},
+	{"April",     TIME_PROP(TIME_MONTH_APRIL),          0},
+	{"Apr",       TIME_PROP(TIME_MONTH_APRIL),          0},
+	{"May",       TIME_PROP(TIME_MONTH_MAY),            0},
+	{"June",      TIME_PROP(TIME_MONTH_JUNE),           0},
+	{"Jun",       TIME_PROP(TIME_MONTH_JUNE),           0},
+	{"July",      TIME_PROP(TIME_MONTH_JULY),           0},
+	{"Jul",       TIME_PROP(TIME_MONTH_JULY),           0},
+	{"August",    TIME_PROP(TIME_MONTH_AUGUST),         0},
+	{"Aug",       TIME_PROP(TIME_MONTH_AUGUST),         0},
+	{"September", TIME_PROP(TIME_MONTH_SEPTEMBER),      0},
+	{"Sep",       TIME_PROP(TIME_MONTH_SEPTEMBER),      0},
+	{"October",   TIME_PROP(TIME_MONTH_OCTOBER),        0},
+	{"Oct",       TIME_PROP(TIME_MONTH_OCTOBER),        0},
+	{"November",  TIME_PROP(TIME_MONTH_NOVEMBER),       0},
+	{"Nov",       TIME_PROP(TIME_MONTH_NOVEMBER),       0},
+	{"December",  TIME_PROP(TIME_MONTH_DECEMBER),       0},
+	{"Dec",       TIME_PROP(TIME_MONTH_DECEMBER),       0},
+	{NULL,        TIME_PROP(TIME_NULL),                 0},
+};
+
+struct time_item {
+	struct dm_list list;
+	const struct time_prop *prop;
+	const char *s;
+	size_t len;
+};
+
+struct time_info {
+	struct dm_pool *mem;
+	struct dm_list *ti_list;
+	time_t *now;
+	time_id_t min_abs_date_granularity;
+	time_id_t max_abs_date_granularity;
+	time_id_t min_abs_time_granularity;
+	time_id_t min_rel_time_granularity;
+};
+
+static int _is_time_num(time_id_t id)
+{
+	return ((id > TIME_NUM__START) && (id < TIME_NUM__END));
+};
+
+/*
+static int _is_time_frame(time_id_t id)
+{
+	return ((id > TIME_FRAME__START) && (id < TIME_FRAME__END));
+};
+*/
+
+static int _is_time_label_date(time_id_t id)
+{
+	return ((id > TIME_LABEL_DATE__START) && (id < TIME_LABEL_DATE__END));
+};
+
+static int _is_time_label_time(time_id_t id)
+{
+	return ((id > TIME_LABEL_TIME__START) && (id < TIME_LABEL_TIME__END));
+};
+
+static int _is_time_unit(time_id_t id)
+{
+	return ((id > TIME_UNIT__START) && (id < TIME_UNIT__END));
+};
+
+static int _is_time_weekday(time_id_t id)
+{
+	return ((id > TIME_WEEKDAY__START) && (id < TIME_WEEKDAY__END));
+};
+
+static int _is_time_month(time_id_t id)
+{
+	return ((id > TIME_MONTH__START) && (id < TIME_MONTH__END));
+};
+
+static const char *_skip_space(const char *s)
+{
+	while (*s && isspace(*s))
+		s++;
+	return s;
+}
+
+/* Move till delim or space */
+static const char *_move_till_item_end(const char *s)
+{
+	char c = *s;
+	int is_num = isdigit(c);
+
+	/*
+	 * Allow numbers to be attached to next token, for example
+	 * it's correct to write "12 hours" as well as "12hours".
+	 */
+	while (c && !isspace(c) && (is_num ? (is_num = isdigit(c)) : 1))
+		c = *++s;
+
+	return s;
+}
+
+static struct time_item *_alloc_time_item(struct dm_pool *mem, time_id_t id,
+					  const char *s, size_t len)
+{
+	struct time_item *ti;
+
+	if (!(ti = dm_pool_zalloc(mem, sizeof(struct time_item)))) {
+		log_error("alloc_time_item: dm_pool_zalloc failed");
+		return NULL;
+	}
+
+	ti->prop = &_time_props[id];
+	ti->s = s;
+	ti->len = len;
+
+	return ti;
+}
+
+static int _add_time_part_to_list(struct dm_pool *mem, struct dm_list *list,
+				  time_id_t id, int minus, const char *s, size_t len)
+{
+	struct time_item *ti1, *ti2;
+
+	if (!(ti1 = _alloc_time_item(mem, minus ? TIME_NUM_MULTIPLIER_NEGATIVE
+						: TIME_NUM_MULTIPLIER, s, len)) ||
+	    !(ti2 = _alloc_time_item(mem, id, s + len, 0)))
+		return 0;
+	dm_list_add(list, &ti1->list);
+	dm_list_add(list, &ti2->list);
+
+	return 1;
+}
+
+static int _get_time(struct dm_pool *mem, const char **str,
+		     struct dm_list *list, int tz)
+{
+	const char *end, *s = *str;
+	int r = 0;
+
+	/* hour */
+	end = _move_till_item_end(s);
+	if (!_add_time_part_to_list(mem, list, tz ? TIME_UNIT_TZ_HOUR : TIME_UNIT_HOUR,
+				    tz == -1, s, end - s))
+		goto out;
+
+	/* minute */
+	if (*end != ':')
+		/* minute required */
+		goto out;
+	s = end + 1;
+	end = _move_till_item_end(s);
+	if (!_add_time_part_to_list(mem, list, tz ? TIME_UNIT_TZ_MINUTE : TIME_UNIT_MINUTE,
+				    tz == -1, s, end - s))
+		goto out;
+
+	/* second */
+	if (*end != ':') {
+		/* second not required */
+		s = end + 1;
+		r = 1;
+		goto out;
+	} else if (tz)
+		/* timezone does not have seconds */
+		goto out;
+
+	s = end + 1;
+	end = _move_till_item_end(s);
+	if (!_add_time_part_to_list(mem, list, TIME_UNIT_SECOND, 0, s, end - s))
+		goto out;
+
+	s = end + 1;
+	r = 1;
+out:
+	*str = s;
+	return r;
+}
+
+static int _preparse_fuzzy_time(const char *s, struct time_info *info)
+{
+	struct dm_list *list;
+	struct time_item *ti;
+	const char *end;
+	int fuzzy = 0;
+	time_id_t id;
+	size_t len;
+	int r = 0;
+	char c;
+
+	if (!(list = dm_pool_alloc(info->mem, sizeof(struct dm_list)))) {
+		log_error("_preparse_fuzzy_time: dm_pool_alloc failed");
+		goto out;
+	}
+	dm_list_init(list);
+	s = _skip_space(s);
+
+	while ((c = *s)) {
+		/*
+		 * If the string consists of -:+, digits or spaces,
+		 * it's not worth looking for fuzzy names here -
+		 * it's standard YYYY-MM-DD HH:MM:SS +-HH:MM format
+		 * and that is parseable by libdm directly.
+		 */
+		if (!(isdigit(c) || (c == '-') || (c == ':') || (c == '+')))
+			fuzzy = 1;
+
+		end = _move_till_item_end(s);
+
+		if (isalpha(c))
+			id = TIME_STR;
+		else if (isdigit(c)) {
+			if (*end == ':') {
+				/* we have time */
+				if (!_get_time(info->mem, &s, list, 0))
+					goto out;
+				continue;
+			}
+			/* we have some other number */
+			id = TIME_NUM;
+		} else if ((c == '-') || (c == '+')) {
+			s++;
+			/* we have timezone */
+			if (!_get_time(info->mem, &s, list, (c == '-') ? -1 : 1))
+				goto out;
+			continue;
+		} else
+			goto out;
+
+		len = end - s;
+		if (!(ti = _alloc_time_item(info->mem, id, s, len)))
+			goto out;
+		dm_list_add(list, &ti->list);
+		s += len;
+		s = _skip_space(s);
+	}
+
+	info->ti_list = list;
+	r = 1;
+out:
+	if (!(r && fuzzy)) {
+		dm_pool_free(info->mem, list);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _match_time_str(struct dm_list *ti_list, struct time_item *ti)
+{
+	struct time_item *ti_context_p = (struct time_item *) dm_list_prev(ti_list, &ti->list);
+	size_t reg_len;
+	int i;
+
+	ti->prop = TIME_PROP(TIME_NULL);
+
+	for (i = 0; _time_reg[i].name; i++) {
+		reg_len = strlen(_time_reg[i].name);
+		if ((ti->len != reg_len) &&
+		    !((_time_reg[i].reg_flags & TIME_REG_PLURAL_S) &&
+		      (ti->len == reg_len+1) && (ti->s[reg_len] == 's')))
+			continue;
+
+		if (!strncasecmp(ti->s, _time_reg[i].name, reg_len)) {
+			ti->prop = _time_reg[i].prop;
+			if ((ti->prop->id > TIME_UNIT__START) && (ti->prop->id < TIME_UNIT__END) &&
+			    ti_context_p && (ti_context_p->prop->id == TIME_NUM))
+				ti_context_p->prop = TIME_PROP(TIME_NUM_MULTIPLIER);
+			break;
+		}
+	}
+
+	return ti->prop->id;
+}
+
+static int _match_time_num(struct dm_list *ti_list, struct time_item *ti)
+{
+	struct time_item *ti_context_p = (struct time_item *) dm_list_prev(ti_list, &ti->list);
+	struct time_item *ti_context_n = (struct time_item *) dm_list_next(ti_list, &ti->list);
+	struct time_item *ti_context_nn = ti_context_n ? (struct time_item *) dm_list_next(ti_list, &ti_context_n->list) : NULL;
+
+	if (ti_context_n &&
+	    (ti_context_n->prop->id > TIME_MONTH__START) &&
+	    (ti_context_n->prop->id < TIME_MONTH__END)) {
+		if (ti_context_nn && ti_context_nn->prop->id == TIME_NUM) {
+			if (ti->len < ti_context_nn->len) {
+				/* 24 Feb 2015 */
+				ti->prop = TIME_PROP(TIME_NUM_DAY);
+				ti_context_nn->prop = TIME_PROP(TIME_NUM_YEAR);
+			} else {
+				/* 2015 Feb 24 */
+				ti->prop = TIME_PROP(TIME_NUM_YEAR);
+				ti_context_nn->prop = TIME_PROP(TIME_NUM_DAY);
+			}
+		} else {
+			if (ti->len <= 2)
+				/* 24 Feb */
+				ti->prop = TIME_PROP(TIME_NUM_DAY);
+			else
+				/* 2015 Feb */
+				ti->prop = TIME_PROP(TIME_NUM_YEAR);
+		}
+	} else if (ti_context_p &&
+		   (ti_context_p->prop->id > TIME_MONTH__START) &&
+		   (ti_context_p->prop->id < TIME_MONTH__END)) {
+		if (ti->len <= 2)
+			/* Feb 24 */
+			ti->prop = TIME_PROP(TIME_NUM_DAY);
+		else
+			/* Feb 2015 */
+			ti->prop = TIME_PROP(TIME_NUM_YEAR);
+	} else
+		ti->prop = TIME_PROP(TIME_NUM_YEAR);
+
+	return ti->prop->id;
+}
+
+static void _detect_time_granularity(struct time_info *info, struct time_item *ti)
+{
+	time_id_t gran = ti->prop->granularity;
+	int is_date, is_abs, is_rel;
+
+	if (gran == TIME_NULL)
+		return;
+
+	is_date = ti->prop->prop_flags & TIME_PROP_DATE;
+	is_abs = ti->prop->prop_flags & TIME_PROP_ABS;
+	is_rel = ti->prop->prop_flags & TIME_PROP_REL;
+
+	if (is_date && is_abs) {
+		if (gran > info->max_abs_date_granularity)
+			info->max_abs_date_granularity = gran;
+		if (gran < info->min_abs_date_granularity)
+			info->min_abs_date_granularity = gran;
+	} else {
+		if (is_abs && (gran < info->min_abs_time_granularity))
+			info->min_abs_time_granularity = gran;
+		else if (is_rel && (gran < info->min_rel_time_granularity))
+			info->min_rel_time_granularity = gran;
+	}
+}
+
+static void _change_to_relative(struct time_info *info, struct time_item *ti)
+{
+	struct time_item *ti2;
+
+	ti2 = ti;
+	while ((ti2 = (struct time_item *) dm_list_prev(info->ti_list, &ti2->list))) {
+		if (ti2->prop->id == TIME_FRAME_AGO)
+			break;
+
+		switch (ti2->prop->id) {
+			case TIME_UNIT_SECOND:
+				ti2->prop = TIME_PROP(TIME_UNIT_SECOND_REL);
+				break;
+			case TIME_UNIT_MINUTE:
+				ti2->prop = TIME_PROP(TIME_UNIT_MINUTE_REL);
+				break;
+			case TIME_UNIT_HOUR:
+				ti2->prop = TIME_PROP(TIME_UNIT_HOUR_REL);
+				break;
+			default:
+				break;
+		}
+	}
+}
+
+static int _recognize_time_items(struct time_info *info)
+{
+	struct time_item *ti;
+
+	/*
+	 * At first, try to recognize strings.
+	 * Also, if there are any items which may be absolute or
+	 * relative and we have "TIME_FRAME_AGO", change them to relative.
+	 */
+	dm_list_iterate_items(ti, info->ti_list) {
+		if ((ti->prop->id == TIME_STR) && !_match_time_str(info->ti_list, ti)) {
+			log_error("Unrecognized string in date/time "
+				  "specification at \"%s\".", ti->s);
+			return 0;
+		}
+		if (ti->prop->id == TIME_FRAME_AGO)
+			_change_to_relative(info, ti);
+	}
+
+	/*
+	 * Now, recognize any numbers and be sensitive to the context
+	 * given by strings we recognized before. Also, detect time
+	 * granularity used (both for absolute and/or relative parts).
+	 */
+	dm_list_iterate_items(ti, info->ti_list) {
+		if ((ti->prop->id == TIME_NUM) && !_match_time_num(info->ti_list, ti)) {
+			log_error("Unrecognized number in date/time "
+				  "specification at \"%s\".", ti->s);
+			return 0;
+		}
+		_detect_time_granularity(info, ti);
+	}
+
+	return 1;
+}
+
+static int _check_time_items(struct time_info *info)
+{
+	struct time_item *ti;
+	uint32_t flags;
+	int rel;
+	int date_is_relative = -1, time_is_relative = -1;
+	int label_time = 0, label_date = 0;
+
+	dm_list_iterate_items(ti, info->ti_list) {
+		flags = ti->prop->prop_flags;
+		rel = flags & TIME_PROP_REL;
+
+		if (flags & TIME_PROP_DATE) {
+			if (date_is_relative < 0)
+				date_is_relative = rel;
+			else if ((date_is_relative ^ rel) &&
+				 (info->max_abs_date_granularity >= info->min_rel_time_granularity)) {
+				log_error("Mixed absolute and relative date "
+					  "specification found at \"%s\".", ti->s);
+				return 0;
+			}
+
+			/* Date label can be used only once and not mixed with other date spec. */
+			if (label_date) {
+				log_error("Ambiguous date specification found at \"%s\".", ti->s);
+				return 0;
+			} else if (_is_time_label_date(ti->prop->id))
+				label_date = 1;
+		}
+
+		else if (flags & TIME_PROP_TIME) {
+			if (time_is_relative < 0)
+				time_is_relative = rel;
+			else if ((time_is_relative ^ rel)) {
+				log_error("Mixed absolute and relative time "
+					  "specification found@\"%s\".", ti->s);
+				return 0;
+			}
+
+			/* Time label can be used only once and not mixed with other time spec. */
+			if (label_time) {
+				log_error("Ambiguous time specification found at \"%s\".", ti->s);
+				return 0;
+			} else if (_is_time_label_time(ti->prop->id))
+				label_time = 1;
+		}
+	}
+
+	return 1;
+}
+
+#define CACHE_ID_TIME_NOW "time_now"
+
+static time_t *_get_now(struct dm_report *rh, struct dm_pool *mem)
+{
+	const void *cached_obj;
+	time_t *now;
+
+	if (!(cached_obj = dm_report_value_cache_get(rh, CACHE_ID_TIME_NOW))) {
+		if (!(now = dm_pool_zalloc(mem, sizeof(time_t)))) {
+			log_error("_get_now: dm_pool_zalloc failed");
+			return NULL;
+		}
+		time(now);
+		if (!dm_report_value_cache_set(rh, CACHE_ID_TIME_NOW, now)) {
+			log_error("_get_now: failed to cache current time");
+			return NULL;
+		}
+	} else
+		now = (time_t *) cached_obj;
+
+	return now;
+}
+
+static void _adjust_time_for_granularity(struct time_info *info, struct tm *tm, time_t *t)
+{
+	switch (info->min_abs_date_granularity) {
+		case TIME_UNIT_YEAR:
+			tm->tm_mon = 0;
+			/* fall through */
+		case TIME_UNIT_MONTH:
+			tm->tm_mday = 1;
+			break;
+		default:
+			break;
+	}
+
+	switch (info->min_abs_time_granularity) {
+		case TIME_UNIT_HOUR:
+			tm->tm_min = 0;
+			/* fall through */
+		case TIME_UNIT_MINUTE:
+			tm->tm_sec = 0;
+			break;
+		case TIME_UNIT__END:
+			if (info->min_rel_time_granularity == TIME_UNIT__END)
+				tm->tm_hour = tm->tm_min = tm->tm_sec = 0;
+			break;
+		default:
+			break;
+	}
+
+	if ((info->min_abs_time_granularity == TIME_UNIT__END) &&
+	    (info->min_rel_time_granularity >= TIME_UNIT_DAY) &&
+	    (info->min_rel_time_granularity <= TIME_UNIT_YEAR))
+		tm->tm_hour = tm->tm_min = tm->tm_sec = 0;
+}
+
+#define SECS_PER_MINUTE 60
+#define SECS_PER_HOUR   3600
+#define SECS_PER_DAY    86400
+
+static int _days_in_month[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
+
+static int _is_leap_year(long year)
+{
+	return (((year % 4==0) && (year % 100 != 0)) || (year % 400 == 0));
+}
+
+static int _get_days_in_month(long month, long year)
+{
+	return (month == 2 && _is_leap_year(year)) ? _days_in_month[month-1] + 1
+						   : _days_in_month[month-1];
+}
+
+static void _get_resulting_time_span(struct time_info *info,
+				     struct tm *tm, time_t t,
+				     time_t *t_result1, time_t *t_result2)
+{
+	time_t t1 = mktime(tm) - t;
+	time_t t2 = t1;
+	struct tm tmp;
+
+	if (info->min_abs_time_granularity != TIME_UNIT__END) {
+		if (info->min_abs_time_granularity == TIME_UNIT_MINUTE)
+			t2 += (SECS_PER_MINUTE - 1);
+		else if (info->min_abs_time_granularity == TIME_UNIT_HOUR)
+			t2 += (SECS_PER_HOUR - 1);
+	} else if (info->min_rel_time_granularity != TIME_UNIT__END) {
+		if (info->min_rel_time_granularity == TIME_UNIT_MINUTE)
+			t1 -= (SECS_PER_MINUTE + 1);
+		else if (info->min_rel_time_granularity == TIME_UNIT_HOUR)
+			t1 -= (SECS_PER_HOUR + 1);
+		else if ((info->min_rel_time_granularity >= TIME_UNIT_DAY) &&
+			(info->min_rel_time_granularity <= TIME_UNIT_YEAR))
+			t2 += (SECS_PER_DAY - 1);
+	} else {
+		if (info->min_abs_date_granularity == TIME_UNIT_MONTH)
+			t2 += (SECS_PER_DAY * _get_days_in_month(tm->tm_mon + 1, tm->tm_year) - 1);
+		else if (info->min_abs_date_granularity != TIME_UNIT__END)
+			t2 += (SECS_PER_DAY - 1);
+	}
+
+	/* Adjust for DST if needed. */
+	localtime_r(&t1, &tmp);
+	if (tmp.tm_isdst)
+		t1 -= SECS_PER_HOUR;
+	localtime_r(&t2, &tmp);
+	if (tmp.tm_isdst)
+		t2 -= SECS_PER_HOUR;
+
+	*t_result1 = t1;
+	*t_result2 = t2;
+}
+
+static int _translate_time_items(struct dm_report *rh, struct time_info *info,
+				 const char **data_out)
+{
+	struct time_item *ti, *ti_p = NULL;
+	long multiplier = 1;
+	struct tm tm_now;
+	time_id_t id;
+	char *end;
+	long num;
+	struct tm tm; /* absolute time */
+	time_t t = 0; /* offset into past before absolute time */
+	time_t t1, t2;
+	char buf[32];
+
+	localtime_r(info->now, &tm_now);
+	tm = tm_now;
+	tm.tm_isdst = 0; /* we'll adjust for dst later */
+	tm.tm_wday = tm.tm_yday = -1;
+
+	dm_list_iterate_items(ti, info->ti_list) {
+		id = ti->prop->id;
+
+		if (_is_time_num(id)) {
+			num = strtol(ti->s, &end, 10);
+			switch (id) {
+				case TIME_NUM_MULTIPLIER_NEGATIVE:
+					multiplier = -num;
+					break;
+				case TIME_NUM_MULTIPLIER:
+					multiplier = num;
+					break;
+				case TIME_NUM_DAY:
+					tm.tm_mday = num;
+					break;
+				case TIME_NUM_YEAR:
+					tm.tm_year = num - 1900;
+					break;
+				default:
+					break;
+			}
+		} else if (_is_time_month(id)) {
+			tm.tm_mon = id - TIME_MONTH__START - 1;
+		} else if (_is_time_label_date(id)) {
+			if (_is_time_weekday(id)) {
+				num = id - TIME_WEEKDAY__START - 1;
+				if (tm_now.tm_wday < num)
+					num = 7 - num + tm_now.tm_wday;
+				else
+					num = tm_now.tm_wday - num;
+				t += num * SECS_PER_DAY;
+			} else switch (id) {
+				case TIME_LABEL_DATE_YESTERDAY:
+					t += SECS_PER_DAY;
+					break;
+				case TIME_LABEL_DATE_TODAY:
+					/* Nothing to do here - we started with today. */
+					break;
+				default:
+					break;
+			}
+		} else if (_is_time_label_time(id)) {
+			switch (id) {
+				case TIME_LABEL_TIME_NOON:
+					tm.tm_hour = 12;
+					tm.tm_min = tm.tm_sec = 0;
+					break;
+				case TIME_LABEL_TIME_MIDNIGHT:
+					tm.tm_hour = tm.tm_min = tm.tm_sec = 0;
+					break;
+				default:
+					break;
+			}
+		} else if (_is_time_unit(id)) {
+			switch (id) {
+				case TIME_UNIT_SECOND:
+					tm.tm_sec = multiplier;
+					break;
+				case TIME_UNIT_SECOND_REL:
+					t += multiplier;
+					break;
+				case TIME_UNIT_MINUTE:
+					tm.tm_min = multiplier;
+					break;
+				case TIME_UNIT_MINUTE_REL:
+					t += (multiplier * SECS_PER_MINUTE);
+					break;
+				case TIME_UNIT_HOUR:
+					tm.tm_hour = multiplier;
+					break;
+				case TIME_UNIT_HOUR_REL:
+					t += (multiplier * SECS_PER_HOUR);
+					break;
+				case TIME_UNIT_AM:
+					if (ti_p->prop->id == TIME_NUM_MULTIPLIER)
+						tm.tm_hour = multiplier;
+					break;
+				case TIME_UNIT_PM:
+					if (_is_time_unit(ti_p->prop->id))
+						t -= 12 * SECS_PER_HOUR;
+					else if (ti_p->prop->id == TIME_NUM_MULTIPLIER)
+						tm.tm_hour = multiplier + 12;
+					break;
+				case TIME_UNIT_DAY:
+					t += multiplier * SECS_PER_DAY;
+					break;
+				case TIME_UNIT_WEEK:
+					t += multiplier * 7 * SECS_PER_DAY;
+					break;
+				case TIME_UNIT_MONTH:
+					/* if months > 12, convert to years first */
+					num = multiplier / 12;
+					tm.tm_year -= num;
+
+					num = multiplier % 12;
+					if (num > (tm.tm_mon + 1)) {
+						tm.tm_year--;
+						tm.tm_mon = 12 - num + tm.tm_mon;
+					} else
+						tm.tm_mon -= num;
+					break;
+				case TIME_UNIT_YEAR:
+					tm.tm_year -= multiplier;
+					break;
+				default:
+					break;
+			}
+		}
+
+		ti_p = ti;
+	}
+
+	_adjust_time_for_granularity(info, &tm, &t);
+	_get_resulting_time_span(info, &tm, t, &t1, &t2);
+
+	dm_pool_free(info->mem, info->ti_list);
+	info->ti_list = NULL;
+
+	dm_snprintf(buf, sizeof(buf), "@%ld:@%ld", t1, t2);
+	if (!(*data_out = dm_pool_strdup(info->mem, buf))) {
+		log_error("_translate_time_items: dm_pool_strdup failed");
+		return 0;
+	}
+
+	return 1;
+}
+
+static const char *_lv_time_handler_parse_fuzzy_name(struct dm_report *rh,
+						     struct dm_pool *mem,
+						     const char *data_in)
+{
+	const char *s = data_in;
+	const char *data_out = NULL;
+	struct time_info info = {.mem = mem,
+				 .ti_list = NULL,
+				 .now = _get_now(rh, mem),
+				 .min_abs_date_granularity = TIME_UNIT__END,
+				 .max_abs_date_granularity = TIME_UNIT__START,
+				 .min_abs_time_granularity = TIME_UNIT__END,
+				 .min_rel_time_granularity = TIME_UNIT__END};
+
+	if (!info.now)
+		goto_out;
+
+	/* recognize top-level parts - string/number/time/timezone? */
+	if (!_preparse_fuzzy_time(s, &info))
+		goto out;
+
+	/* recognize each part in more detail, also look at the context around if needed */
+	if (!_recognize_time_items(&info))
+		goto out;
+
+	/* check if the combination of items is allowed or whether it makes sense at all */
+	if (!_check_time_items(&info))
+		goto out;
+
+	/* translate items into final time range */
+	if (!_translate_time_items(rh, &info, &data_out))
+		goto out;
+out:
+	if (info.ti_list)
+		dm_pool_free(info.mem, info.ti_list);
+	return data_out;
+}
+
+static void *_lv_time_handler_get_dynamic_value(struct dm_report *rh,
+						struct dm_pool *mem,
+						const char *data_in)
+{
+	time_t t1, t2;
+	time_t *result;
+
+	if (sscanf(data_in, "@%ld:@%ld", &t1, &t2) != 2) {
+		log_error("Failed to get value for parsed time specification.");
+		return NULL;
+	}
+
+	if (!(result = dm_pool_alloc(mem, 2 * sizeof(time_t)))) {
+		log_error("Failed to allocate space to store time range.");
+		return NULL;
+	}
+
+	result[0] = t1;
+	result[1] = t2;
+
+	return result;
+}
+
+static int lv_time_handler(struct dm_report *rh, struct dm_pool *mem,
+			   uint32_t field_num,
+			   dm_report_reserved_action_t action,
+			   const void *data_in, const void **data_out)
+{
+	*data_out = NULL;
+	if (!data_in)
+		return 1;
+
+	switch (action) {
+		case DM_REPORT_RESERVED_PARSE_FUZZY_NAME:
+			*data_out = _lv_time_handler_parse_fuzzy_name(rh, mem, data_in);
+			break;
+		case DM_REPORT_RESERVED_GET_DYNAMIC_VALUE:
+			if (!(*data_out = _lv_time_handler_get_dynamic_value(rh, mem, data_in)))
+				return 0;
+			break;
+		default:
+			return -1;
+	}
+
+	return 1;
+}
+
 /*
  * Get type reserved value - the value returned is the direct value of that type.
  */
diff --git a/lib/report/values.h b/lib/report/values.h
index 742cb50..728760c 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -87,6 +87,7 @@ FIELD_RESERVED_VALUE(NOFLAG, lv_read_ahead, lv_read_ahead_auto, "", &_siz_max, "
 FIELD_RESERVED_VALUE(NAMED, lv_when_full, lv_when_full_error, "", "error", "error", "error when full", "error if no space")
 FIELD_RESERVED_VALUE(NAMED, lv_when_full, lv_when_full_queue, "", "queue", "queue", "queue when full", "queue if no space")
 FIELD_RESERVED_VALUE(NOFLAG, lv_when_full, lv_when_full_undef, "", "", "", "undefined")
+FIELD_RESERVED_VALUE(NAMED | RANGE | FUZZY | DYNAMIC, lv_time, lv_time_fuzzy, "", lv_time_handler, NULL)
 
 /* Reserved values for SEG fields */
 FIELD_RESERVED_VALUE(NOFLAG, cache_policy, cache_policy_undef, "", "", "", "undefined")
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 2ec98d6..7afbb8d 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2273,11 +2273,13 @@ static int _check_reserved_values_supported(const struct dm_report_field_type fi
 	static uint32_t supported_reserved_types = DM_REPORT_FIELD_TYPE_NUMBER |
 						   DM_REPORT_FIELD_TYPE_SIZE |
 						   DM_REPORT_FIELD_TYPE_PERCENT |
-						   DM_REPORT_FIELD_TYPE_STRING;
+						   DM_REPORT_FIELD_TYPE_STRING |
+						   DM_REPORT_FIELD_TYPE_TIME;
 	static uint32_t supported_reserved_types_with_range = DM_REPORT_FIELD_RESERVED_VALUE_RANGE |
 							      DM_REPORT_FIELD_TYPE_NUMBER |
 							      DM_REPORT_FIELD_TYPE_SIZE |
-							      DM_REPORT_FIELD_TYPE_PERCENT;
+							      DM_REPORT_FIELD_TYPE_PERCENT |
+							      DM_REPORT_FIELD_TYPE_TIME;
 
 
 	if (!reserved_values)


