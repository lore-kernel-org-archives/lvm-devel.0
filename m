From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 24 Oct 2013 17:55:15 +0000 (UTC)
Subject: master - clean-up: Remove redundant faulty logic
Message-ID: <20131024175515.1306361065@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=772fa460d1ef7dede99478e30de756136ea0c7aa
Commit:        772fa460d1ef7dede99478e30de756136ea0c7aa
Parent:        4c0db84948ad616930e217f20768a4285ca67c5a
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Oct 23 22:44:04 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Oct 23 22:44:04 2013 -0500

clean-up: Remove redundant faulty logic

Remove conditional that boils down to "if yes or no, then do".  The
previous condition in the statement is sufficient and the extra
(always true) condition is unnecessary.
---
 tools/lvchange.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 6ae9720..1931c03 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -772,11 +772,8 @@ static int lvchange_writemostly(struct logical_volume *lv)
 			if (!(pv_names[i] = dm_pool_zalloc(lv->vg->vgmem, tmp_str_len + 3)))
 				return_0;
 
-			if (tmp_str_len < 3 ||
-			    ((tmp_str[tmp_str_len - 2] != ':') &&
-			     ((tmp_str[tmp_str_len - 1] != 't') ||
-			      (tmp_str[tmp_str_len - 1] != 'y') ||
-			      (tmp_str[tmp_str_len - 1] != 'n'))))
+			if ((tmp_str_len < 3) ||
+			    (tmp_str[tmp_str_len - 2] != ':'))
 				/* Default to 'y' if no mode specified */
 				sprintf(pv_names[i], "%s:y", tmp_str);
 			else


