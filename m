From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 29 Sep 2020 08:45:27 +0000 (GMT)
Subject: master - debug: update debug message
Message-ID: <20200929084527.7A2953844008@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c89c5a40f8aeda6939a9596615c5d5c1471f352
Commit:        0c89c5a40f8aeda6939a9596615c5d5c1471f352
Parent:        bd0d4de4e2bbf7c858482193936311376c916025
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 26 14:54:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 29 10:43:56 2020 +0200

debug: update debug message

---
 lib/activate/activate.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7168d24fa..311d33a52 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2934,8 +2934,7 @@ int revert_lv(struct cmd_context *cmd, const struct logical_volume *lv)
 
 	ret = lv_resume_if_active(cmd, NULL, 0, 0, 1, lv_committed(lv));
 
-	critical_section_dec(cmd, "unlocking on resume");
+	critical_section_dec(cmd, "unlocking on revert");
 
 	return ret;
 }
-


