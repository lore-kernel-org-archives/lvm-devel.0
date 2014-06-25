From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 25 Jun 2014 06:52:34 +0000 (UTC)
Subject: master - coverity: mark new switch cases with 'fall through' comment for coverity to stop complaining
Message-ID: <20140625065234.B154460DEA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e329c3146d91aba94f77a6d5da149e31b20ce60b
Commit:        e329c3146d91aba94f77a6d5da149e31b20ce60b
Parent:        3208396ce5ef1c754e8e164f84dbc97727ddb5a4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 25 08:51:37 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 25 08:51:37 2014 +0200

coverity: mark new switch cases with 'fall through' comment for coverity to stop complaining

---
 libdm/libdm-report.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 180bb9b..00c3d3f 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1354,6 +1354,7 @@ static int _compare_selection_field(struct dm_report *rh,
 				 */
 				if (*(const uint64_t *) f->sort_value > DM_PERCENT_100)
 					return 0;
+				/* fall through */
 			case DM_REPORT_FIELD_TYPE_NUMBER:
 				r = _cmp_field_int(field_id, *(const uint64_t *) f->sort_value, fs->v.i, fs->flags);
 				break;
@@ -1839,7 +1840,7 @@ static const char *_tok_value_regex(struct dm_report *rh,
 		case '(': c = ')'; break;
 		case '{': c = '}'; break;
 		case '[': c = ']'; break;
-		case '"':
+		case '"': /* fall through */
 		case '\'': c = *s; break;
 		default:  c = 0;
 	}
@@ -2075,7 +2076,9 @@ static const char *_tok_value(struct dm_report *rh,
 			break;
 
 		case DM_REPORT_FIELD_TYPE_NUMBER:
+			/* fall through */
 		case DM_REPORT_FIELD_TYPE_SIZE:
+			/* fall through */
 		case DM_REPORT_FIELD_TYPE_PERCENT:
 			if (!(s = _tok_value_number(s, begin, end))) {
 				log_error("Failed to parse numeric value "


