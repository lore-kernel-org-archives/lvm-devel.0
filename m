From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 23 Jul 2013 12:34:55 +0000 (UTC)
Subject: master - cleanup: suppress compiler warning
Message-ID: <20130723123455.1A396613AF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3670fe92ba05c9555159ee887bc96e1da41e6682
Commit:        3670fe92ba05c9555159ee887bc96e1da41e6682
Parent:        eb5a6a0d1a867aa793e68f99c9a01027b182af65
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 23 13:32:47 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 23 13:32:47 2013 +0100

cleanup: suppress compiler warning

---
 tools/lvchange.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 3b40659..3ba78e6 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -749,10 +749,10 @@ static int lvchange_writemostly(struct logical_volume *lv)
 				return_0;
 
 			if (tmp_str_len < 3 ||
-			    (tmp_str[tmp_str_len - 2] != ':') &&
-			    ((tmp_str[tmp_str_len - 1] != 't') ||
-			     (tmp_str[tmp_str_len - 1] != 'y') ||
-			     (tmp_str[tmp_str_len - 1] != 'n')))
+			    ((tmp_str[tmp_str_len - 2] != ':') &&
+			     ((tmp_str[tmp_str_len - 1] != 't') ||
+			      (tmp_str[tmp_str_len - 1] != 'y') ||
+			      (tmp_str[tmp_str_len - 1] != 'n'))))
 				/* Default to 'y' if no mode specified */
 				sprintf(pv_names[i], "%s:y", tmp_str);
 			else


