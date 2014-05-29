From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 May 2014 12:33:00 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select: fix factor (size unit) check for numeric only fields
Message-ID: <20140529123300.6CC19610C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=142523ebb9c08eb82fb647e56562a378741e0b05
Commit:        142523ebb9c08eb82fb647e56562a378741e0b05
Parent:        94509e38f29ebcd78f4e653846de50df0f2121b8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 14:26:12 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu May 29 14:30:22 2014 +0200

report: select: fix factor (size unit) check for numeric only fields

---
 libdm/libdm-report.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 1b3c70c..33c9ddd 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1643,7 +1643,7 @@ static const char *_tok_value(const struct dm_report_field_type *ft,
 			*factor = dm_units_to_factor(s, &c, 0, &tmp);
 
 			if (expected_type == DM_REPORT_FIELD_TYPE_NUMBER) {
-				if (factor) {
+				if (*factor) {
 					log_error("Found size unit specifier but "
 						  "only numeric value expected for "
 						  "selection field %s.",ft->id);
@@ -1925,7 +1925,8 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		if (!(last = _tok_value_regex(ft, last, &vs, &ve, &flags)))
 			goto_bad;
 	} else {
-		if (ft->flags == DM_REPORT_FIELD_TYPE_SIZE)
+		if (ft->flags == DM_REPORT_FIELD_TYPE_SIZE ||
+		    ft->flags == DM_REPORT_FIELD_TYPE_NUMBER)
 			custom = &factor;
 		else if (ft->flags == DM_REPORT_FIELD_TYPE_STRING_LIST)
 			custom = &str_list;


