From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 30 Jun 2015 15:19:08 +0000 (UTC)
Subject: master - libdm: Rename struct time_value variables.
Message-ID: <20150630151908.E25CF606D7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6ad48f0e580950a74775c8dc1058d8e6122ae69
Commit:        f6ad48f0e580950a74775c8dc1058d8e6122ae69
Parent:        ded279f826f0eec41b17a79b6e186daf920b613c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jun 30 16:17:22 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 30 16:17:22 2015 +0100

libdm: Rename struct time_value variables.

warning: declaration of ???time??? shadows a global declaration
---
 libdm/libdm-report.c |   48 ++++++++++++++++++++++++------------------------
 1 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index b808b0d..18710d3 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2795,7 +2795,7 @@ static int _local_tz_offset(time_t t_local)
 
 static void _get_final_time(time_range_t range, struct tm *tm,
 			    int tz_supplied, int offset,
-			    struct time_value *time)
+			    struct time_value *tval)
 {
 
 	struct tm tm_up = *tm;
@@ -2834,9 +2834,9 @@ static void _get_final_time(time_range_t range, struct tm *tm,
 			break;
 	}
 
-	time->range = (range != RANGE_NONE);
-	time->t1 = mktime(tm);
-	time->t2 = mktime(&tm_up) - 1;
+	tval->range = (range != RANGE_NONE);
+	tval->t1 = mktime(tm);
+	tval->t2 = mktime(&tm_up) - 1;
 
 	if (tz_supplied) {
 		/*
@@ -2845,13 +2845,13 @@ static void _get_final_time(time_range_t range, struct tm *tm,
 		 * to our local timezone and adjust times
 		 * so they represent time in our local timezone.
 		 */
-		offset -= _local_tz_offset(time->t1);
-		time->t1 -= offset;
-		time->t2 -= offset;
+		offset -= _local_tz_offset(tval->t1);
+		tval->t1 -= offset;
+		tval->t2 -= offset;
 	}
 }
 
-static int _parse_formatted_date_time(char *str, struct time_value *time)
+static int _parse_formatted_date_time(char *str, struct time_value *tval)
 {
 	time_range_t range = RANGE_NONE;
 	struct tm tm;
@@ -2874,7 +2874,7 @@ static int _parse_formatted_date_time(char *str, struct time_value *time)
 	if (*str)
 		return 0;
 
-	_get_final_time(range, &tm, tz_supplied, gmt_offset, time);
+	_get_final_time(range, &tm, tz_supplied, gmt_offset, tval);
 
 	return 1;
 }
@@ -2882,7 +2882,7 @@ static int _parse_formatted_date_time(char *str, struct time_value *time)
 static const char *_tok_value_time(const struct dm_report_field_type *ft,
 				   struct dm_pool *mem, const char *s,
 				   const char **begin, const char **end,
-				   struct time_value *time)
+				   struct time_value *tval)
 {
 	char *time_str = NULL;
 	const char *r = NULL;
@@ -2906,9 +2906,9 @@ static const char *_tok_value_time(const struct dm_report_field_type *ft,
 			goto out;
 		}
 
-		time->range = 0;
-		time->t1 = (time_t) t;
-		time->t2 = 0;
+		tval->range = 0;
+		tval->t1 = (time_t) t;
+		tval->t2 = 0;
 		r = s;
 	} else {
 		c = _get_and_skip_quote_char(&s);
@@ -2920,7 +2920,7 @@ static const char *_tok_value_time(const struct dm_report_field_type *ft,
 			goto out;
 		}
 
-		if (!_parse_formatted_date_time(time_str, time))
+		if (!_parse_formatted_date_time(time_str, tval))
 			goto_out;
 		r = s;
 	}
@@ -2953,7 +2953,7 @@ static const char *_tok_value(struct dm_report *rh,
 {
 	int expected_type = ft->flags & DM_REPORT_FIELD_TYPE_MASK;
 	struct selection_str_list **str_list;
-	struct time_value *time;
+	struct time_value *tval;
 	uint64_t *factor;
 	const char *tmp;
 	char c;
@@ -3041,8 +3041,8 @@ static const char *_tok_value(struct dm_report *rh,
 			break;
 
 		case DM_REPORT_FIELD_TYPE_TIME:
-			time = (struct time_value *) custom;
-			if (!(s = _tok_value_time(ft, mem, s, begin, end, time))) {
+			tval = (struct time_value *) custom;
+			if (!(s = _tok_value_time(ft, mem, s, begin, end, tval))) {
 				log_error("Failed to parse time value "
 					  "for selection field %s.", ft->id);
 				return NULL;
@@ -3119,7 +3119,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 	struct field_properties *fp, *found = NULL;
 	struct field_selection *fs;
 	const char *field_id;
-	struct time_value *time;
+	struct time_value *tval;
 	uint64_t factor;
 	char *s;
 
@@ -3287,10 +3287,10 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
 						fs->value->next->v.t = (((time_t *) rvw->value)[1]);
 				} else {
-					time = (struct time_value *) custom;
-					fs->value->v.t = time->t1;
-					if (time->range)
-						fs->value->next->v.t = time->t2;
+					tval = (struct time_value *) custom;
+					fs->value->v.t = tval->t1;
+					if (tval->range)
+						fs->value->next->v.t = tval->t2;
 					if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_TIME, &fs->value->v.t, NULL)) {
 						log_error("Time value found in selection is reserved.");
 						goto error;
@@ -3433,7 +3433,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	const struct dm_report_field_type *ft;
 	struct selection_str_list *str_list;
 	struct reserved_value_wrapper rvw = {0};
-	struct time_value time;
+	struct time_value tval;
 	uint64_t factor;
 	void *custom = NULL;
 	char *tmp;
@@ -3517,7 +3517,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		    ft->flags == DM_REPORT_FIELD_TYPE_PERCENT)
 			custom = &factor;
 		else if (ft->flags & DM_REPORT_FIELD_TYPE_TIME)
-			custom = &time;
+			custom = &tval;
 		else if (ft->flags == DM_REPORT_FIELD_TYPE_STRING_LIST)
 			custom = &str_list;
 		else


