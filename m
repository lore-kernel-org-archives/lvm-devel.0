From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Nov 2015 18:01:38 +0000 (UTC)
Subject: master - cleanup: unify NULL custom check
Message-ID: <20151117180138.12A2660F16@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=121341e52c8cb3bf14571cad0c3d90c1ec9d717d
Commit:        121341e52c8cb3bf14571cad0c3d90c1ec9d717d
Parent:        cad3568def7f82ae58c3585a94ceb377bb155167
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 17 13:19:39 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 17 19:01:25 2015 +0100

cleanup: unify NULL custom check

Unify testing of NULL custom pointer.
Resolve 'factor' only in required if() branch.
---
 libdm/libdm-report.c |   72 ++++++++++++++++++++++++++++---------------------
 1 files changed, 41 insertions(+), 31 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 2457335..140a8d7 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -3211,7 +3211,9 @@ static const char *_tok_value(struct dm_report *rh,
 			break;
 
 		case DM_REPORT_FIELD_TYPE_STRING_LIST:
-			str_list = (struct selection_str_list **) custom;
+			if (!(str_list = (struct selection_str_list **) custom))
+				goto_bad;
+
 			s = _tok_value_string_list(ft, mem, s, begin, end, str_list);
 			if (!(*str_list)) {
 				log_error("Failed to parse string list value "
@@ -3232,8 +3234,6 @@ static const char *_tok_value(struct dm_report *rh,
 				return NULL;
 			}
 
-			factor = (uint64_t *) custom;
-
 			if (*s == DM_PERCENT_CHAR) {
 				s++;
 				c = DM_PERCENT_CHAR;
@@ -3244,24 +3244,29 @@ static const char *_tok_value(struct dm_report *rh,
 							"numeric" : "size", ft->id);
 					return NULL;
 				}
-			} else if ((*factor = dm_units_to_factor(s, &c, 0, &tmp))) {
-				s = tmp;
-				if (expected_type != DM_REPORT_FIELD_TYPE_SIZE) {
-					log_error("Found size unit specifier "
-						  "but %s value expected for "
-						  "selection field %s.",
-						  expected_type == DM_REPORT_FIELD_TYPE_NUMBER ?
-							"numeric" : "percent", ft->id);
-					return NULL;
+			} else {
+				if (!(factor = (uint64_t *) custom))
+					goto_bad;
+
+				if ((*factor = dm_units_to_factor(s, &c, 0, &tmp))) {
+					s = tmp;
+					if (expected_type != DM_REPORT_FIELD_TYPE_SIZE) {
+						log_error("Found size unit specifier "
+							  "but %s value expected for "
+							  "selection field %s.",
+							  expected_type == DM_REPORT_FIELD_TYPE_NUMBER ?
+							  "numeric" : "percent", ft->id);
+						return NULL;
+					}
+				} else if (expected_type == DM_REPORT_FIELD_TYPE_SIZE) {
+					/*
+					 * If size unit is not defined in the selection
+					 * and the type expected is size, use use 'm'
+					 * (1 MiB) for the unit by default. This is the
+					 * same behaviour as seen in lvcreate -L <size>.
+					 */
+					*factor = 1024*1024;
 				}
-			} else if (expected_type == DM_REPORT_FIELD_TYPE_SIZE) {
-				/*
-				 * If size unit is not defined in the selection
-				 * and the type expected is size, use use 'm'
-				 * (1 MiB) for the unit by default. This is the
-				 * same behaviour as seen in lvcreate -L <size>.
-				 */
-				*factor = 1024*1024;
 			}
 
 			*flags |= expected_type;
@@ -3273,7 +3278,9 @@ static const char *_tok_value(struct dm_report *rh,
 			break;
 
 		case DM_REPORT_FIELD_TYPE_TIME:
-			tval = (struct time_value *) custom;
+			if (!(tval = (struct time_value *) custom))
+				goto_bad;
+
 			if (!(s = _tok_value_time(ft, mem, s, begin, end, tval))) {
 				log_error("Failed to parse time value "
 					  "for selection field %s.", ft->id);
@@ -3290,6 +3297,10 @@ static const char *_tok_value(struct dm_report *rh,
 	}
 
 	return s;
+bad:
+	log_error(INTERNAL_ERROR "Forbidden NULL custom detected.");
+
+	return NULL;
 }
 
 /*
@@ -3412,7 +3423,8 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 	}
 
 	if (((rvw->reserved && (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)) ||
-	    (((flags & DM_REPORT_FIELD_TYPE_MASK) == DM_REPORT_FIELD_TYPE_TIME) && ((struct time_value *) custom)->range))
+	     (((flags & DM_REPORT_FIELD_TYPE_MASK) == DM_REPORT_FIELD_TYPE_TIME) &&
+	      custom && ((struct time_value *) custom)->range))
 		 &&
 	    !(fs->value->next = dm_pool_zalloc(rh->selection->mem, sizeof(struct field_selection_value)))) {
 		log_error(_field_selection_value_alloc_failed_msg, field_id);
@@ -3529,10 +3541,8 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				}
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING_LIST:
-				if (!custom) {
-					log_error(INTERNAL_ERROR "Custom selection list is undefined.");
-					goto error;
-				}
+				if (!custom)
+                                        goto_bad;
 				fs->value->v.l = *(struct selection_str_list **)custom;
 				if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING_LIST, fs->value->v.l, NULL)) {
 					log_error("String list value found in selection is reserved.");
@@ -3545,11 +3555,8 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
 						fs->value->next->v.t = (((const time_t *) rvw->value)[1]);
 				} else {
-					if (!custom) {
-						log_error(INTERNAL_ERROR "Custom time value is undefined.");
-						goto error;
-					}
-					tval = (struct time_value *) custom;
+					if (!(tval = (struct time_value *) custom))
+						goto_bad;
 					fs->value->v.t = tval->t1;
 					if (tval->range)
 						fs->value->next->v.t = tval->t2;
@@ -3567,8 +3574,11 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 	}
 
 	return fs;
+bad:
+	log_error(INTERNAL_ERROR "Forbiden NULL custom detected.");
 error:
 	dm_pool_free(rh->selection->mem, fs);
+
 	return NULL;
 }
 


