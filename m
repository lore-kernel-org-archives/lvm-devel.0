From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:30 +0000 (UTC)
Subject: master - coverity: check for dm_snprintf
Message-ID: <20160223204130.61D8D6055D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e3a9eab0ebf06fb5ed969269e11cb9b31d033fa
Commit:        9e3a9eab0ebf06fb5ed969269e11cb9b31d033fa
Parent:        a9634e993a44760e164f0ed12aaeaa6903cc9a6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 21:03:50 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:17 2016 +0100

coverity: check for dm_snprintf

Check return state like everywhere else.
---
 lib/report/report.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index ed6202c..bd7c163 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1446,7 +1446,8 @@ static int _do_get_kernel_cache_settings_list(struct dm_pool *mem,
 		buf_len = strlen(key) + strlen(value) + 2;
 		if (!(buf = dm_pool_alloc(mem, buf_len)))
 			return_0;
-		dm_snprintf(buf, buf_len, "%s=%s", key, value);
+		if (dm_snprintf(buf, buf_len, "%s=%s", key, value) < 0)
+			return_0;
 		if (!str_list_add_no_dup_check(mem, result, buf))
 			return_0;
 	}


