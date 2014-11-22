From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Nov 2014 23:50:49 +0000 (UTC)
Subject: master - libdm: report fix memleak on error path
Message-ID: <20141122235049.A33D960E36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=678cc4e3752ec74c7647a23eb3131439c37b3328
Commit:        678cc4e3752ec74c7647a23eb3131439c37b3328
Parent:        8eb111dfb81c4615826747653d88259e311b2982
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 22 22:40:40 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Nov 23 00:49:04 2014 +0100

libdm: report fix memleak on error path

When _alloc_selection_node() fails, rh should be destroyed.

Use 'bad:' label since we have goto_bad with stack embeded.
---
 libdm/libdm-report.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index f768750..0dfbc30 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2849,24 +2849,24 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 	}
 
 	if (!(root = _alloc_selection_node(rh->mem, SEL_OR)))
-		return_0;
+		goto_bad;
 
 	if (!_parse_or_ex(rh, selection, &fin, root))
-		goto error;
+		goto_bad;
 
 	next = _skip_space(fin);
 	if (*next) {
 		log_error("Expecting logical operator");
 		log_error(_sel_syntax_error_at_msg, next);
 		log_error(_sel_help_ref_msg);
-		goto error;
+		goto bad;
 	}
 
 	_dm_report_init_update_types(rh, report_types);
 
 	rh->selection_root = root;
 	return rh;
-error:	
+bad:
 	dm_report_free(rh);
 	return NULL;
 }


