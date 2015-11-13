From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:04 +0000 (UTC)
Subject: master - libdm: put in secure check
Message-ID: <20151113101904.9A6A1610A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d74e1291cd43f50010c22fb2c071d92390a26d28
Commit:        d74e1291cd43f50010c22fb2c071d92390a26d28
Parent:        0128770d6d881c7f30fc5e22137d1b20ce003e13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 11 22:51:23 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:17:05 2015 +0100

libdm: put in secure check

Coverity complains about NULL deref - while this cannot currently
happen, put in secure INTERNAL_ERROR.
---
 libdm/libdm-report.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index b9906d8..38dde07 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -3527,6 +3527,10 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				}
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING_LIST:
+				if (!custom) {
+					log_error(INTERNAL_ERROR "Custom selection list is undefined.");
+					goto error;
+				}
 				fs->value->v.l = *(struct selection_str_list **)custom;
 				if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING_LIST, fs->value->v.l, NULL)) {
 					log_error("String list value found in selection is reserved.");


