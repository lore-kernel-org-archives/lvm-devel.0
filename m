From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 20 Jan 2015 17:16:24 +0000 (UTC)
Subject: master - report: Fix warning in _str_list_append.
Message-ID: <20150120171624.AA4806105D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=404c834e14657645d70d19b825d328bff5b165b7
Commit:        404c834e14657645d70d19b825d328bff5b165b7
Parent:        87e80b6aac630f0c26d128006c975841a76ca890
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 20 17:15:28 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 20 17:15:28 2015 +0000

report: Fix warning in _str_list_append.

../../lib/report/report.c: In function ???_str_list_append???:
../../lib/report/report.c:256: warning: declaration of ???dup??? shadows a global declaration
---
 lib/report/report.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index b3365b0..3331e5e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -253,11 +253,14 @@ struct _str_list_append_baton {
 static int _str_list_append(const char *line, void *baton)
 {
 	struct _str_list_append_baton *b = baton;
-	const char *dup = dm_pool_strdup(b->mem, line);
-	if (!dup)
+	const char *line2 = dm_pool_strdup(b->mem, line);
+
+	if (!line2)
 		return_0;
-	if (!str_list_add(b->mem, b->result, dup))
+
+	if (!str_list_add(b->mem, b->result, line2))
 		return_0;
+
 	return 1;
 }
 


