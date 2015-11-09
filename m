From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:28 +0000 (UTC)
Subject: master - libdm: exlicitly check for NULL
Message-ID: <20151109092828.E681F60CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84303dc17aeca9773d5644e4beccc267ab7a3153
Commit:        84303dc17aeca9773d5644e4beccc267ab7a3153
Parent:        f6c140e200177ef527c8943fbe0a94e2e6bd8b3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:44:26 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

libdm: exlicitly check for NULL

Coverity: another explict check for NULL, where coverity fails to
see it.
---
 libdm/libdm-report.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index b2e70d5..23d0955 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -437,7 +437,8 @@ static int _report_field_string_list(struct dm_report *rh,
 	/* one item */
 	if (list_size == 1) {
 		sl = (struct dm_str_list *) dm_list_first(data);
-		if (!(sort_value->value = field->report_string = dm_pool_strdup(rh->mem, sl->str))) {
+		if (!sl ||
+		    !(sort_value->value = field->report_string = dm_pool_strdup(rh->mem, sl->str))) {
 			log_error("dm_report_field_string_list: dm_pool_strdup failed");
 			goto out;
 		}
@@ -2218,6 +2219,7 @@ static const char *_tok_value_number(const char *s,
 	int is_float = 0;
 
 	*begin = s;
+	/* coverity[assign_where_compare_meant] */
 	while ((!is_float && (*s == '.') && ((is_float = 1))) || isdigit(*s))
 		s++;
 	*end = s;


