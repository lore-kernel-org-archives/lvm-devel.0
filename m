From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Jul 2014 14:41:53 +0000 (UTC)
Subject: master - report: also report linear and striped for lv_target_type
Message-ID: <20140710144153.3643C60CFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3063b48602220b0aa5e1ad7a91dc4ca60d717e36
Commit:        3063b48602220b0aa5e1ad7a91dc4ca60d717e36
Parent:        d169ff1e039ecdfb1efac0a6464ca149d71d8767
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 10 16:41:42 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 10 16:41:42 2014 +0200

report: also report linear and striped for lv_target_type

---
 lib/report/report.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 6dc792b..d193c47 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1590,6 +1590,10 @@ static int _lvtargettype_disp(struct dm_report *rh, struct dm_pool *mem,
 		target_type = "snapshot";
 	else if (lv_is_virtual(lv))
 		target_type = "virtual";
+	else if (lv_is_linear(lv))
+		target_type = "linear";
+	else if (lv_is_striped(lv))
+		target_type = "striped";
 
 	return _string_disp(rh, mem, field, &target_type, private);
 }


