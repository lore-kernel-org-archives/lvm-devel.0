From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 19 Jun 2014 14:17:57 +0000 (UTC)
Subject: master - report: display explicit fields first, then implicit fields in field help
Message-ID: <20140619141757.E421860D98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f16da6ef23c75b966f94a27b45ca57bacaa13d20
Commit:        f16da6ef23c75b966f94a27b45ca57bacaa13d20
Parent:        a40bc36b2e360ad357820e6de2f5ec9fa64a6772
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 19 15:54:22 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 19 16:14:53 2014 +0200

report: display explicit fields first, then implicit fields in field help

It's better to have implicit fields at the very end of the output
so users can see them without scrolling back if the list of fields
is long (the "help" is also an implicit field now so it should be
easily visible).
---
 libdm/libdm-report.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 012dca4..fd03052 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -653,11 +653,12 @@ static void _display_fields(struct dm_report *rh, int display_all_fields_item,
 	if ((tmp = _get_longest_field_id_len(rh->fields)) > id_len)
 		id_len = tmp;
 
-	_display_fields_more(rh, _implicit_report_fields, id_len,
-			     display_all_fields_item, display_field_types);
-	log_warn(" ");
 	_display_fields_more(rh, rh->fields, id_len, display_all_fields_item,
 			     display_field_types);
+	log_warn(" ");
+	_display_fields_more(rh, _implicit_report_fields, id_len,
+			     display_all_fields_item, display_field_types);
+
 }
 
 /*


