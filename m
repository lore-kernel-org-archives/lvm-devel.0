From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 23 Jun 2014 10:22:46 +0000 (UTC)
Subject: master - select: also mark uncomparable/unselectable fields in field/selection help
Message-ID: <20140623102246.6DE8A616BA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69075d0b4386f0bd112efc237c86c340872b022f
Commit:        69075d0b4386f0bd112efc237c86c340872b022f
Parent:        2d48ef7f04e0b3b14d7a9bf622979e42141f34f2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 23 10:46:45 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 23 12:20:49 2014 +0200

select: also mark uncomparable/unselectable fields in field/selection help

---
 libdm/libdm-report.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 3d16e5a..67f63d5 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -633,8 +633,9 @@ static void _display_fields_more(struct dm_report *rh,
 			}
 		}
 		/* FIXME Add line-wrapping at terminal width (or 80 cols) */
-		log_warn("  %-*s - %s%s%s%s", (int) id_len, fields[f].id, fields[f].desc,
+		log_warn("  %-*s - %s%s%s%s%s", (int) id_len, fields[f].id, fields[f].desc,
 					      display_field_types ? " [" : "",
+					      display_field_types ? fields[f].flags & FLD_CMP_UNCOMPARABLE ? "unselectable " : "" : "",
 					      display_field_types ? _get_field_type_name(fields[f].flags & DM_REPORT_FIELD_TYPE_MASK) : "",
 					      display_field_types ? "]" : "");
 		last_desc = desc;


