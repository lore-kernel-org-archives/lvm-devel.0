From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 23 Jun 2014 10:22:48 +0000 (UTC)
Subject: master - select: add message about 'help' field to get more help on each error hit during selection parsing
Message-ID: <20140623102248.8C4EE60302@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c3c35787423b3b3d29fdb6a86cf796a1847cce4
Commit:        9c3c35787423b3b3d29fdb6a86cf796a1847cce4
Parent:        69075d0b4386f0bd112efc237c86c340872b022f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 23 12:12:01 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 23 12:21:17 2014 +0200

select: add message about 'help' field to get more help on each error hit during selection parsing

Inform about 'help' to get more help about selection fields and operators
after each syntax error hit:

  "Use 'help' for selection to get more help."
---
 libdm/libdm-report.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 67f63d5..957a4c9 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2396,7 +2396,8 @@ out_reserved_values:
 	log_warn(" ");
 }
 
-static char _sel_syntax_error_at_msg[] = "Selection syntax error at '%s'.";
+static const char _sel_syntax_error_at_msg[] = "Selection syntax error at '%s'.";
+static const char _sel_help_ref_msg[] = "Use \'help\' for selection to get more help.";
 
 /*
  * Selection parser
@@ -2460,6 +2461,8 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 			c = we[0];
 			tmp = (char *) we;
 			tmp[0] = '\0';
+			_display_fields(rh, 0, 1);
+			log_warn(" ");
 			log_error("Selection field is uncomparable: %s.", ws);
 			tmp[0] = c;
 			goto bad;
@@ -2522,6 +2525,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	return sn;
 bad:
 	log_error(_sel_syntax_error_at_msg, s);
+	log_error(_sel_help_ref_msg);
 	*next = s;
 	return NULL;
 }
@@ -2695,6 +2699,7 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 	if (*next) {
 		log_error("Expecting logical operator");
 		log_error(_sel_syntax_error_at_msg, next);
+		log_error(_sel_help_ref_msg);
 		goto error;
 	}
 


