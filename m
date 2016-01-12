From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 12 Jan 2016 15:14:52 +0000 (UTC)
Subject: master - report: use proper string reference in _string_disp call for _cache_policy_disp fn
Message-ID: <20160112151452.7EFD560C44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=176b4aaebeb8b885d5df16172a5bc32481beda59
Commit:        176b4aaebeb8b885d5df16172a5bc32481beda59
Parent:        1a3ee6402ecf761554040a551f6c7f52b92f73ca
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 12 16:13:56 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 12 16:14:23 2016 +0100

report: use proper string reference in _string_disp call for _cache_policy_disp fn

---
 lib/report/report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 17aa5c0..9f44212 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1429,7 +1429,7 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	return _string_disp(rh, mem, field, seg->policy_name, private);
+	return _string_disp(rh, mem, field, &seg->policy_name, private);
 }
 
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,


