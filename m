From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Jun 2015 13:20:10 +0000 (UTC)
Subject: master - report: add support for time (basic)
Message-ID: <20150630132010.6BC9560AA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ded279f826f0eec41b17a79b6e186daf920b613c
Commit:        ded279f826f0eec41b17a79b6e186daf920b613c
Parent:        89d355ea04560dba54aa8b7b5a20950b9eb3f653
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 21 15:19:03 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 30 15:15:10 2015 +0200

report: add support for time (basic)

This patch adds support for time values used in reporting fields.
The raw values are always stored as number of seconds since epoch.

The support that comes with this patch is the basic one which allows
only for recognition of strictly formatted date and time in selection
criteria (the format follows a subset of formats defined by ISO 8601):

  date time timezone

  date:
    YYYY-MM-DD (or shortly YYYYMMDD)
    YYYY-MM (shortly YYYYMM), auto DD=1
    YYYY, auto MM=01 and DD=01

  time:
    hh:mm:ss (or shortly hhmmss)
    hh:mm (or shortly hhmm), auto ss=0
    hh (or shortly hh), auto mm=0, auto ss=0

  timezone (always with + or - sign):
    +hh:mm or -hh:mm (or shortly +hhmm or -hhmm)
    +hh or -hh

Or directly the time (number of seconds) since Epoch (1970-01-01 00:00:00 UTC)
when the number value is prefixed by "@":

   @number_of_seconds_since_epoch

This patch also adds aliases for comparison operators
used together with time values which are more intuitive
to use:
  since (as alias for >=)
  after (as alias for >)
  until (as alias for <=)
  before (as alias for <)

For example:

$ lvmconfig --type full report/time_format
time_format="%Y-%m-%d %T %z %Z [%s]"

$ lvs -o name,time vg
  LV    Time
  lvol0 2015-06-28 21:25:41 +0200 CEST [1435519541]
  lvol1 2015-06-30 03:25:43 +0200 CEST [1435627543]
  lvol2 2015-04-26 14:52:20 +0200 CEST [1430052740]
  lvol3 2015-06-30 14:52:23 +0200 CEST [1435668743]

$ lvs vg -o name,time -S 'time since "2015-04-26 15:00" && time until "2015-06-30"'
  LV    Time
  lvol0 2015-06-28 21:25:41 +0200 CEST [1435519541]
  lvol1 2015-06-30 03:25:43 +0200 CEST [1435627543]
  lvol3 2015-06-30 14:52:23 +0200 CEST [1435668743]

$ lvs vg -o name,time -S 'time since "2015-04-26 15:00" && time until "2015-06-30 6:00"'
  LV    Time
  lvol0 2015-06-28 21:25:41 +0200 CEST [1435519541]
  lvol1 2015-06-30 03:25:43 +0200 CEST [1435627543]

$ lvs vg -o name,time -S 'time since @1435519541'
  LV    Time
  lvol0 2015-06-28 21:25:41 +0200 CEST [1435519541]
  lvol1 2015-06-30 03:25:43 +0200 CEST [1435627543]
  lvol3 2015-06-30 14:52:23 +0200 CEST [1435668743]

This is basic time recognition support that is directly a part of
libdevmapper. Recognition of more free-form expressions will be a
part of subsequent patches.
---
 WHATS_NEW_DM                 |    2 +
 lib/properties/prop_common.h |    3 +-
 lib/report/columns.h         |    2 +-
 lib/report/report.c          |    1 +
 libdm/libdevmapper.h         |    1 +
 libdm/libdm-report.c         |  608 ++++++++++++++++++++++++++++++++++++++++--
 6 files changed, 591 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 75e572a..bef2e0d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.100 - 
 ================================
+  Add since, after, until and before time operators to be used in selection.
+  Add support for time in reports and selection: DM_REPORT_FIELD_TYPE_TIME.
   Support report reserved value ranges: DM_REPORT_FIELD_RESERVED_VALUE_RANGE.
   Support report reserved value names: DM_REPORT_FIELD_RESERVED_VALUE_NAMED.
   Add DM_CONFIG_VALUE_FMT_{INT_OCTAL,STRING_NO_QUOTES} config value format flag.
diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
index 9cc963a..19b8f70 100644
--- a/lib/properties/prop_common.h
+++ b/lib/properties/prop_common.h
@@ -127,8 +127,9 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 #define BIN 3
 #define SIZ 4
 #define PCT 5
-#define STR_LIST 6
+#define TIM 6
 #define SNUM 7              /* Signed Number */
+#define STR_LIST 8
 
 #define FIELD_MODIFIABLE 0x00000001
 #define FIELD(type, strct, field_type, head, field, width, fn, id, desc, settable) \
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 06282c5..1576c28 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -84,7 +84,7 @@ FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin and cach
 FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, pool_lv, "For thin volumes, the thin pool LV for this volume.", 0)
 FIELD(LVS, lv, STR_LIST, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration profile attached to this LV.", 0)
-FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
+FIELD(LVS, lv, TIM, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR_LIST, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 1c741e4..025b896 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2064,6 +2064,7 @@ static const struct dm_report_object_type _devtypes_report_types[] = {
 #define BIN DM_REPORT_FIELD_TYPE_NUMBER
 #define SIZ DM_REPORT_FIELD_TYPE_SIZE
 #define PCT DM_REPORT_FIELD_TYPE_PERCENT
+#define TIM DM_REPORT_FIELD_TYPE_TIME
 #define STR_LIST DM_REPORT_FIELD_TYPE_STRING_LIST
 #define SNUM DM_REPORT_FIELD_TYPE_NUMBER
 #define FIELD(type, strct, sorttype, head, field, width, func, id, desc, writeable) \
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 38f42aa..7e30d8e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1682,6 +1682,7 @@ struct dm_report_field;
 #define DM_REPORT_FIELD_TYPE_SIZE			0x00000040
 #define DM_REPORT_FIELD_TYPE_PERCENT			0x00000080
 #define DM_REPORT_FIELD_TYPE_STRING_LIST		0x00000100
+#define DM_REPORT_FIELD_TYPE_TIME			0x00000200
 
 /* For use with reserved values only! */
 #define DM_REPORT_FIELD_RESERVED_VALUE_MASK		0x0000000F
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 4348db1..b808b0d 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -18,6 +18,7 @@
 #include <ctype.h>
 #include <math.h>  /* fabs() */
 #include <float.h> /* DBL_EPSILON */
+#include <time.h>
 
 /*
  * Internal flags
@@ -100,11 +101,13 @@ struct op_def {
 #define FLD_CMP_LT		0x01000000
 #define FLD_CMP_REGEX		0x02000000
 #define FLD_CMP_NUMBER		0x04000000
+#define FLD_CMP_TIME		0x08000000
 /*
- * #define FLD_CMP_STRING 0x08000000
- * We could defined FLD_CMP_STRING here for completeness here,
+ * #define FLD_CMP_STRING 0x10000000
+ * We could define FLD_CMP_STRING here for completeness here,
  * but it's not needed - we can check operator compatibility with
- * field type by using FLD_CMP_REGEX and FLD_CMP_NUMBER flags only.
+ * field type by using FLD_CMP_REGEX, FLD_CMP_NUMBER and
+ * FLD_CMP_TIME flags only.
  */
 
 /*
@@ -115,12 +118,16 @@ struct op_def {
 static struct op_def _op_cmp[] = {
 	{ "=~", FLD_CMP_REGEX, "Matching regular expression. [regex]" },
 	{ "!~", FLD_CMP_REGEX|FLD_CMP_NOT, "Not matching regular expression. [regex]" },
-	{ "=", FLD_CMP_EQUAL, "Equal to. [number, size, percent, string, string list]" },
-	{ "!=", FLD_CMP_NOT|FLD_CMP_EQUAL, "Not equal to. [number, size, percent, string, string_list]" },
-	{ ">=", FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL, "Greater than or equal to. [number, size, percent]" },
-	{ ">", FLD_CMP_NUMBER|FLD_CMP_GT, "Greater than. [number, size, percent]" },
-	{ "<=", FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL, "Less than or equal to. [number, size, percent]" },
-	{ "<", FLD_CMP_NUMBER|FLD_CMP_LT, "Less than. [number, size, percent]" },
+	{ "=", FLD_CMP_EQUAL, "Equal to. [number, size, percent, string, string list, time]" },
+	{ "!=", FLD_CMP_NOT|FLD_CMP_EQUAL, "Not equal to. [number, size, percent, string, string_list, time]" },
+	{ ">=", FLD_CMP_NUMBER|FLD_CMP_TIME|FLD_CMP_GT|FLD_CMP_EQUAL, "Greater than or equal to. [number, size, percent, time]" },
+	{ ">", FLD_CMP_NUMBER|FLD_CMP_TIME|FLD_CMP_GT, "Greater than. [number, size, percent, time]" },
+	{ "<=", FLD_CMP_NUMBER|FLD_CMP_TIME|FLD_CMP_LT|FLD_CMP_EQUAL, "Less than or equal to. [number, size, percent, time]" },
+	{ "<", FLD_CMP_NUMBER|FLD_CMP_TIME|FLD_CMP_LT, "Less than. [number, size, percent, time]" },
+	{ "since", FLD_CMP_TIME|FLD_CMP_GT|FLD_CMP_EQUAL, "Since specified time (same as '>='). [time]" },
+	{ "after", FLD_CMP_TIME|FLD_CMP_GT, "After specified time (same as '>'). [time]"},
+	{ "until", FLD_CMP_TIME|FLD_CMP_LT|FLD_CMP_EQUAL, "Until specified time (same as '<='). [time]"},
+	{ "before", FLD_CMP_TIME|FLD_CMP_LT, "Before specified time (same as '<'). [time]"},
 	{ NULL, 0, NULL }
 };
 
@@ -166,6 +173,7 @@ struct field_selection_value {
 	union {
 		const char *s;
 		uint64_t i;
+		time_t t;
 		double d;
 		struct dm_regex *r;
 		struct selection_str_list *l;
@@ -662,6 +670,7 @@ static const char *_get_field_type_name(unsigned field_type)
 		case DM_REPORT_FIELD_TYPE_NUMBER: return "number";
 		case DM_REPORT_FIELD_TYPE_SIZE: return "size";
 		case DM_REPORT_FIELD_TYPE_PERCENT: return "percent";
+		case DM_REPORT_FIELD_TYPE_TIME: return "time";
 		case DM_REPORT_FIELD_TYPE_STRING_LIST: return "string list";
 		default: return "unknown";
 	}
@@ -1363,6 +1372,9 @@ static int _do_check_value_is_strictly_reserved(unsigned type, const void *res_v
 		case DM_REPORT_FIELD_TYPE_STRING_LIST:
 			/* FIXME Add comparison for string list */
 			break;
+		case DM_REPORT_FIELD_TYPE_TIME:
+			/* FIXME Add comparison for time */
+			break;
 	}
 
 	return 0;
@@ -1504,6 +1516,43 @@ static int _cmp_field_string(struct dm_report *rh __attribute__((unused)),
 	return 0;
 }
 
+static int _cmp_field_time(struct dm_report *rh,
+			   uint32_t field_num, const char *field_id,
+			   time_t val, struct field_selection *fs)
+{
+	int range = fs->value->next != NULL;
+	time_t sel1 = fs->value->v.t;
+	time_t sel2 = range ? fs->value->next->v.t : 0;
+
+	switch(fs->flags & FLD_CMP_MASK) {
+		case FLD_CMP_EQUAL:
+			return range ? ((val >= sel1) && (val <= sel2)) : val == sel1;
+		case FLD_CMP_NOT|FLD_CMP_EQUAL:
+			return range ? ((val >= sel1) && (val <= sel2)) : val != sel1;
+		case FLD_CMP_TIME|FLD_CMP_GT:
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_TIME, &val, fs))
+				return 0;
+			return range ? val > sel2 : val > sel1;
+		case FLD_CMP_TIME|FLD_CMP_GT|FLD_CMP_EQUAL:
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_TIME, &val, fs))
+				return 0;
+			return val >= sel1;
+		case FLD_CMP_TIME|FLD_CMP_LT:
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_TIME, &val, fs))
+				return 0;
+			return val < sel1;
+		case FLD_CMP_TIME|FLD_CMP_LT|FLD_CMP_EQUAL:
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_TIME, &val, fs))
+				return 0;
+			return range ? val <= sel2 : val <= sel1;
+		default:
+			log_error(INTERNAL_ERROR "_cmp_field_time: unsupported time "
+				  "comparison type for field %s", field_id);
+	}
+
+	return 0;
+}
+
 /* Matches if all items from selection string list match list value strictly 1:1. */
 static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *val,
 					     const struct selection_str_list *sel)
@@ -1664,6 +1713,9 @@ static int _compare_selection_field(struct dm_report *rh,
 			case DM_REPORT_FIELD_TYPE_STRING_LIST:
 				r = _cmp_field_string_list(rh, f->props->field_num, field_id, (const struct str_list_sort_value *) f->sort_value, fs);
 				break;
+			case DM_REPORT_FIELD_TYPE_TIME:
+				r = _cmp_field_time(rh, f->props->field_num, field_id, *(const time_t *) f->sort_value, fs);
+				break;
 			default:
 				log_error(INTERNAL_ERROR "_compare_selection_field: unknown field type for field %s", field_id);
 		}
@@ -2428,6 +2480,456 @@ bad:
 	return s;
 }
 
+struct time_value {
+	int range;
+	time_t t1;
+	time_t t2;
+};
+
+static const char *_out_of_range_msg = "Field selection value %s out of supported range for field %s.";
+
+/*
+ * Standard formatted date and time - ISO8601.
+ *
+ * date time timezone
+ *
+ * date:
+ * YYYY-MM-DD (or shortly YYYYMMDD)
+ * YYYY-MM (shortly YYYYMM), auto DD=1
+ * YYYY, auto MM=01 and DD=01
+ *
+ * time:
+ * hh:mm:ss (or shortly hhmmss)
+ * hh:mm (or shortly hhmm), auto ss=0
+ * hh (or shortly hh), auto mm=0, auto ss=0
+ *
+ * timezone:
+ * +hh:mm or -hh:mm (or shortly +hhmm or -hhmm)
+ * +hh or -hh
+*/
+
+#define DELIM_DATE '-'
+#define DELIM_TIME ':'
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
+typedef enum {
+	RANGE_NONE,
+	RANGE_SECOND,
+	RANGE_MINUTE,
+	RANGE_HOUR,
+	RANGE_DAY,
+	RANGE_MONTH,
+	RANGE_YEAR
+} time_range_t;
+
+static char *_get_date(char *str, struct tm *tm, time_range_t *range)
+{
+	static const char incorrect_date_format_msg[] = "Incorrect date format.";
+	time_range_t tmp_range = RANGE_NONE;
+	long n1 = -1, n2 = -1, n3 = -1;
+	char *s = str, *end;
+	size_t len = 0;
+
+	if (!isdigit(*s))
+		/* we need a year at least */
+		return NULL;
+
+	n1 = strtol(s, &end, 10);
+	if (*end == DELIM_DATE) {
+		len += (4 - (end - s)); /* diff in length from standard YYYY */
+		s = end + 1;
+		if (isdigit(*s)) {
+			n2 = strtol(s, &end, 10);
+			len += (2 - (end - s)); /* diff in length from standard MM */
+			if (*end == DELIM_DATE) {
+				s = end + 1;
+				n3 = strtol(s, &end, 10);
+				len += (2 - (end - s)); /* diff in length from standard DD */
+			}
+		}
+	}
+
+	len = len + end - str;
+
+	/* variations from standard YYYY-MM-DD */
+	if (n3 == -1) {
+		if (n2 == -1) {
+			if (len == 4) {
+				/* YYYY */
+				tmp_range = RANGE_YEAR;
+				n3 = n2 = 1;
+			} else if (len == 6) {
+				/* YYYYMM */
+				tmp_range = RANGE_MONTH;
+				n3 = 1;
+				n2 = n1 % 100;
+				n1 = n1 / 100;
+			} else if (len == 8) {
+				tmp_range = RANGE_DAY;
+				/* YYYYMMDD */
+				n3 = n1 % 100;
+				n2 = (n1 / 100) % 100;
+				n1 = n1 / 10000;
+			} else {
+				log_error(incorrect_date_format_msg);
+				return NULL;
+			}
+		} else {
+			if (len == 7) {
+				tmp_range = RANGE_MONTH;
+				/* YYYY-MM */
+				n3 = 1;
+			} else {
+				log_error(incorrect_date_format_msg);
+				return NULL;
+			}
+		}
+	}
+
+	if (n2 < 1 || n2 > 12) {
+		log_error("Specified month out of range.");
+		return NULL;
+	}
+
+	if (n3 < 1 || n3 > _get_days_in_month(n2, n1)) {
+		log_error("Specified day out of range.");
+		return NULL;
+	}
+
+	if (tmp_range == RANGE_NONE)
+		tmp_range = RANGE_DAY;
+
+	tm->tm_year = n1 - 1900;
+	tm->tm_mon = n2 - 1;
+	tm->tm_mday = n3;
+	*range = tmp_range;
+
+	return (char *) _skip_space(end);
+}
+
+static char *_get_time(char *str, struct tm *tm, time_range_t *range)
+{
+	static const char incorrect_time_format_msg[] = "Incorrect time format.";
+	time_range_t tmp_range = RANGE_NONE;
+	long n1 = -1, n2 = -1, n3 = -1;
+	char *s = str, *end;
+	size_t len = 0;
+
+	if (!isdigit(*s)) {
+		/* time is not compulsory */
+		tm->tm_hour = tm->tm_min = tm->tm_sec = 0;
+		return (char *) _skip_space(s);
+	}
+
+	n1 = strtol(s, &end, 10);
+	if (*end == DELIM_TIME) {
+		len += (2 - (end - s)); /* diff in length from standard HH */
+		s = end + 1;
+		if (isdigit(*s)) {
+			n2 = strtol(s, &end, 10);
+			len += (2 - (end - s)); /* diff in length from standard MM */
+			if (*end == DELIM_TIME) {
+				s = end + 1;
+				n3 = strtol(s, &end, 10);
+				len += (2 - (end - s)); /* diff in length from standard SS */
+			}
+		}
+	}
+
+	len = len + end - str;
+
+	/* variations from standard HH:MM:SS */
+	if (n3 == -1) {
+		if (n2 == -1) {
+			if (len == 2) {
+				/* HH */
+				tmp_range = RANGE_HOUR;
+				n3 = n2 = 0;
+			} else if (len == 4) {
+				/* HHMM */
+				tmp_range = RANGE_MINUTE;
+				n3 = 0;
+				n2 = n1 % 100;
+				n1 = n1 / 100;
+			} else if (len == 6) {
+				/* HHMMSS */
+				tmp_range = RANGE_SECOND;
+				n3 = n1 % 100;
+				n2 = (n1 / 100) % 100;
+				n1 = n1 / 10000;
+			} else {
+				log_error(incorrect_time_format_msg);
+				return NULL;
+			}
+		} else {
+			if (len == 5) {
+				/* HH:MM */
+				tmp_range = RANGE_MINUTE;
+				n3 = 0;
+			} else {
+				log_error(incorrect_time_format_msg);
+				return NULL;
+			}
+		}
+	}
+
+	if (n1 < 0 || n1 > 23) {
+		log_error("Specified hours out of range.");
+		return NULL;
+	}
+
+	if (n2 < 0 || n2 > 60) {
+		log_error("Specified minutes out of range.");
+		return NULL;
+	}
+
+	if (n3 < 0 || n3 > 60) {
+		log_error("Specified seconds out of range.");
+		return NULL;
+	}
+
+	/* Just time without exact date is incomplete! */
+	if (*range != RANGE_DAY) {
+		log_error("Full date specification needed.");
+		return NULL;
+	}
+
+	tm->tm_hour = n1;
+	tm->tm_min = n2;
+	tm->tm_sec = n3;
+	*range = tmp_range;
+
+	return (char *) _skip_space(end);
+}
+
+/* The offset is always an absolute offset against GMT! */
+static char *_get_tz(char *str, int *tz_supplied, int *offset)
+{
+	long n1 = -1, n2 = -1;
+	char *s = str, *end;
+	int sign = 1; /* +HH:MM by default */
+	size_t len = 0;
+
+	*tz_supplied = 0;
+	*offset = 0;
+
+	if (!isdigit(*s)) {
+		if (*s == '+')  {
+			sign = 1;
+			s = s + 1;
+		} else if (*s == '-') {
+			sign = -1;
+			s = s + 1;
+		} else
+			return (char *) _skip_space(s);
+	}
+
+	n1 = strtol(s, &end, 10);
+	if (*end == DELIM_TIME) {
+		len = (2 - (end - s)); /* diff in length from standard HH */
+		s = end + 1;
+		if (isdigit(*s)) {
+			n2 = strtol(s, &end, 10);
+			len = (2 - (end - s)); /* diff in length from standard MM */
+		}
+	}
+
+	len = len + end - s;
+
+	/* variations from standard HH:MM */
+	if (n2 == -1) {
+		if (len == 2) {
+			/* HH */
+			n2 = 0;
+		} else if (len == 4) {
+			/* HHMM */
+			n2 = n1 % 100;
+			n1 = n1 / 100;
+		} else
+			return NULL;
+	}
+
+	if (n2 < 0 || n2 > 60)
+		return NULL;
+
+	if (n1 < 0 || n1 > 14)
+		return NULL;
+
+	/* timezone offset in seconds */
+	*offset = sign * ((n1 * 3600) + (n2 * 60));
+	*tz_supplied = 1;
+	return (char *) _skip_space(end);
+}
+
+static int _local_tz_offset(time_t t_local)
+{
+	struct tm tm_gmt;
+	time_t t_gmt;
+
+	gmtime_r(&t_local, &tm_gmt);
+	t_gmt = mktime(&tm_gmt);
+
+	/*
+	 * gmtime returns time that is adjusted
+	 * for DST.Subtract this adjustment back
+	 * to give us proper *absolute* offset
+	 * for our local timezone.
+	 */
+	if (tm_gmt.tm_isdst)
+		t_gmt -= 3600;
+
+	return t_local - t_gmt;
+}
+
+static void _get_final_time(time_range_t range, struct tm *tm,
+			    int tz_supplied, int offset,
+			    struct time_value *time)
+{
+
+	struct tm tm_up = *tm;
+
+	switch (range) {
+		case RANGE_SECOND:
+			if (tm_up.tm_sec < 59) {
+				tm_up.tm_sec += 1;
+				break;
+			}
+		case RANGE_MINUTE:
+			if (tm_up.tm_min < 59) {
+				tm_up.tm_min += 1;
+				break;
+			}
+		case RANGE_HOUR:
+			if (tm_up.tm_hour < 23) {
+				tm_up.tm_hour += 1;
+				break;
+			}
+		case RANGE_DAY:
+			if (tm_up.tm_mday < _get_days_in_month(tm_up.tm_mon, tm_up.tm_year)) {
+				tm_up.tm_mday += 1;
+				break;
+			}
+		case RANGE_MONTH:
+			if (tm_up.tm_mon < 11) {
+				tm_up.tm_mon += 1;
+				break;
+			}
+		case RANGE_YEAR:
+			tm_up.tm_year += 1;
+			break;
+		case RANGE_NONE:
+			/* nothing to do here */
+			break;
+	}
+
+	time->range = (range != RANGE_NONE);
+	time->t1 = mktime(tm);
+	time->t2 = mktime(&tm_up) - 1;
+
+	if (tz_supplied) {
+		/*
+		 * The 'offset' is with respect to the GMT.
+		 * Calculate what the offset is with respect
+		 * to our local timezone and adjust times
+		 * so they represent time in our local timezone.
+		 */
+		offset -= _local_tz_offset(time->t1);
+		time->t1 -= offset;
+		time->t2 -= offset;
+	}
+}
+
+static int _parse_formatted_date_time(char *str, struct time_value *time)
+{
+	time_range_t range = RANGE_NONE;
+	struct tm tm;
+	int gmt_offset;
+	int tz_supplied;
+
+	tm.tm_year = tm.tm_mday = tm.tm_mon = -1;
+	tm.tm_hour = tm.tm_min = tm.tm_sec = -1;
+	tm.tm_isdst = tm.tm_wday = tm.tm_yday = -1;
+
+	if (!(str = _get_date(str, &tm, &range)))
+		return 0;
+
+	if (!(str = _get_time(str, &tm, &range)))
+		return 0;
+
+	if (!(str = _get_tz(str, &tz_supplied, &gmt_offset)))
+		return 0;
+
+	if (*str)
+		return 0;
+
+	_get_final_time(range, &tm, tz_supplied, gmt_offset, time);
+
+	return 1;
+}
+
+static const char *_tok_value_time(const struct dm_report_field_type *ft,
+				   struct dm_pool *mem, const char *s,
+				   const char **begin, const char **end,
+				   struct time_value *time)
+{
+	char *time_str = NULL;
+	const char *r = NULL;
+	uint64_t t;
+	char c;
+
+	s = _skip_space(s);
+
+	if (*s == '@') {
+		/* Absolute time value in number of seconds since epoch. */
+		if (!(s = _tok_value_number(s+1, begin, end)))
+			goto_out;
+
+		if (!(time_str = dm_pool_strndup(mem, *begin, *end - *begin))) {
+			log_error("_tok_value_time: dm_pool_strndup failed");
+			goto out;
+		}
+
+		if (((t = strtoull(time_str, NULL, 10)) == ULLONG_MAX) && errno == ERANGE) {
+			log_error(_out_of_range_msg, time_str, ft->id);
+			goto out;
+		}
+
+		time->range = 0;
+		time->t1 = (time_t) t;
+		time->t2 = 0;
+		r = s;
+	} else {
+		c = _get_and_skip_quote_char(&s);
+		if (!(s = _tok_value_string(s, begin, end, c, SEL_AND | SEL_OR | SEL_PRECEDENCE_PE, NULL)))
+			goto_out;
+
+		if (!(time_str = dm_pool_strndup(mem, *begin, *end - *begin))) {
+			log_error("tok_value_time: dm_pool_strndup failed");
+			goto out;
+		}
+
+		if (!_parse_formatted_date_time(time_str, time))
+			goto_out;
+		r = s;
+	}
+out:
+	if (time_str)
+		dm_pool_free(mem, time_str);
+	return r;
+}
+
 /*
  * Input:
  *   ft              - field type for which the value is parsed
@@ -2451,6 +2953,7 @@ static const char *_tok_value(struct dm_report *rh,
 {
 	int expected_type = ft->flags & DM_REPORT_FIELD_TYPE_MASK;
 	struct selection_str_list **str_list;
+	struct time_value *time;
 	uint64_t *factor;
 	const char *tmp;
 	char c;
@@ -2530,6 +3033,28 @@ static const char *_tok_value(struct dm_report *rh,
 			}
 
 			*flags |= expected_type;
+			/*
+			 * FLD_CMP_NUMBER shares operators with FLD_CMP_TIME,
+			 * but we have NUMBER here, so remove FLD_CMP_TIME.
+			 */
+			*flags &= ~FLD_CMP_TIME;
+			break;
+
+		case DM_REPORT_FIELD_TYPE_TIME:
+			time = (struct time_value *) custom;
+			if (!(s = _tok_value_time(ft, mem, s, begin, end, time))) {
+				log_error("Failed to parse time value "
+					  "for selection field %s.", ft->id);
+				return NULL;
+			}
+
+			*flags |= DM_REPORT_FIELD_TYPE_TIME;
+			/*
+			 * FLD_CMP_TIME shares operators with FLD_CMP_NUMBER,
+			 * but we have TIME here, so remove FLD_CMP_NUMBER.
+			 */
+			*flags &= ~FLD_CMP_NUMBER;
+			break;
 	}
 
 	return s;
@@ -2588,13 +3113,13 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 						       struct reserved_value_wrapper *rvw,
 						       void *custom)
 {
-	static const char *_out_of_range_msg = "Field selection value %s out of supported range for field %s.";
 	static const char *_field_selection_value_alloc_failed_msg = "dm_report: struct field_selection_value allocation failed for selection field %s";
 	const struct dm_report_field_type *fields = implicit ? _implicit_report_fields
 							     : rh->fields;
 	struct field_properties *fp, *found = NULL;
 	struct field_selection *fs;
 	const char *field_id;
+	struct time_value *time;
 	uint64_t factor;
 	char *s;
 
@@ -2632,7 +3157,9 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 		goto error;
 	}
 
-	if (rvw->reserved && (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE) &&
+	if (((rvw->reserved && (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)) ||
+	    (((flags & DM_REPORT_FIELD_TYPE_MASK) == DM_REPORT_FIELD_TYPE_TIME) && ((struct time_value *) custom)->range))
+		 &&
 	    !(fs->value->next = dm_pool_zalloc(rh->selection->mem, sizeof(struct field_selection_value)))) {
 		log_error(_field_selection_value_alloc_failed_msg, field_id);
 		goto error;
@@ -2666,7 +3193,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 			goto error;
 		}
 	} else {
-		/* STRING, NUMBER, SIZE or STRING_LIST */
+		/* STRING, NUMBER, SIZE, PERCENT, STRING_LIST, TIME */
 		if (!(s = dm_pool_strndup(rh->selection->mem, v, len))) {
 			log_error("dm_report: dm_pool_strndup for value "
 				  "of selection field %s", field_id);
@@ -2754,6 +3281,22 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 					goto error;
 				}
 				break;
+			case DM_REPORT_FIELD_TYPE_TIME:
+				if (rvw->value) {
+					fs->value->v.t = *(time_t *) rvw->value;
+					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
+						fs->value->next->v.t = (((time_t *) rvw->value)[1]);
+				} else {
+					time = (struct time_value *) custom;
+					fs->value->v.t = time->t1;
+					if (time->range)
+						fs->value->next->v.t = time->t2;
+					if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_TIME, &fs->value->v.t, NULL)) {
+						log_error("Time value found in selection is reserved.");
+						goto error;
+					}
+				}
+				break;
 			default:
 				log_error(INTERNAL_ERROR "_create_field_selection: "
 					  "unknown type of selection field %s", field_id);
@@ -2845,7 +3388,7 @@ out_reserved_values:
 	log_warn("  Comparison operators:");
 	t = _op_cmp;
 	for (; t->string; t++)
-		log_warn("    %4s  - %s", t->string, t->desc);
+		log_warn("    %6s  - %s", t->string, t->desc);
 	log_warn(" ");
 	log_warn("  Logical and grouping operators:");
 	t = _op_log;
@@ -2890,6 +3433,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	const struct dm_report_field_type *ft;
 	struct selection_str_list *str_list;
 	struct reserved_value_wrapper rvw = {0};
+	struct time_value time;
 	uint64_t factor;
 	void *custom = NULL;
 	char *tmp;
@@ -2940,25 +3484,40 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		goto bad;
 	}
 
-	/* some operators can compare only numeric fields (NUMBER, SIZE or PERCENT) */
-	if ((flags & FLD_CMP_NUMBER) &&
-	    (ft->flags != DM_REPORT_FIELD_TYPE_NUMBER) &&
-	    (ft->flags != DM_REPORT_FIELD_TYPE_SIZE) &&
-	    (ft->flags != DM_REPORT_FIELD_TYPE_PERCENT)) {
-		_display_selection_help(rh);
-		log_error("Operator can be used only with number, size or percent fields: %s", ws);
-		goto bad;
-	}
-
 	/* comparison value */
 	if (flags & FLD_CMP_REGEX) {
+		/*
+		 * REGEX value
+		 */
 		if (!(last = _tok_value_regex(rh, ft, last, &vs, &ve, &flags, &rvw)))
 			goto_bad;
 	} else {
+		/*
+		 * STRING, NUMBER, SIZE, PERCENT, STRING_LIST, TIME value
+		 */
+		if (flags & FLD_CMP_NUMBER) {
+			if (!(ft->flags & (DM_REPORT_FIELD_TYPE_NUMBER |
+					   DM_REPORT_FIELD_TYPE_SIZE |
+					   DM_REPORT_FIELD_TYPE_PERCENT |
+					   DM_REPORT_FIELD_TYPE_TIME))) {
+				_display_selection_help(rh);
+				log_error("Operator can be used only with number, size, time or percent fields: %s", ws);
+				goto bad;
+			}
+		} else if (flags & FLD_CMP_TIME) {
+			if (!(ft->flags & DM_REPORT_FIELD_TYPE_TIME)) {
+				_display_selection_help(rh);
+				log_error("Operator can be used only with time fields: %s", ws);
+				goto bad;
+			}
+		}
+
 		if (ft->flags == DM_REPORT_FIELD_TYPE_SIZE ||
 		    ft->flags == DM_REPORT_FIELD_TYPE_NUMBER ||
 		    ft->flags == DM_REPORT_FIELD_TYPE_PERCENT)
 			custom = &factor;
+		else if (ft->flags & DM_REPORT_FIELD_TYPE_TIME)
+			custom = &time;
 		else if (ft->flags == DM_REPORT_FIELD_TYPE_STRING_LIST)
 			custom = &str_list;
 		else
@@ -3274,7 +3833,8 @@ static int _row_compare(const void *a, const void *b)
 		sfa = (*rowa->sort_fields)[cnt];
 		sfb = (*rowb->sort_fields)[cnt];
 		if ((sfa->props->flags & DM_REPORT_FIELD_TYPE_NUMBER) ||
-		    (sfa->props->flags & DM_REPORT_FIELD_TYPE_SIZE)) {
+		    (sfa->props->flags & DM_REPORT_FIELD_TYPE_SIZE) ||
+		    (sfa->props->flags & DM_REPORT_FIELD_TYPE_TIME)) {
 			const uint64_t numa =
 			    *(const uint64_t *) sfa->sort_value;
 			const uint64_t numb =


