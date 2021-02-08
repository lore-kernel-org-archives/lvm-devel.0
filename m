From: David Teigland <teigland@sourceware.org>
Date: Mon,  8 Feb 2021 16:23:35 +0000 (GMT)
Subject: main - lvmcache: remove unused variable from last commit
Message-ID: <20210208162335.BCBC63851C0B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df4c50396bfce6586a063d04861f9d1d8b1aeb31
Commit:        df4c50396bfce6586a063d04861f9d1d8b1aeb31
Parent:        87ee401eea3c3c3958ec5cda6e5c246b80503b8c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 8 10:22:30 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 8 10:22:56 2021 -0600

lvmcache: remove unused variable from last commit

---
 lib/cache/lvmcache.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 03c5f4d4f..5c573286d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1056,7 +1056,6 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
 	struct device *dev;
 	const char *device_hint;
 	uint64_t devsize, pvsize;
-	int dropped = 0;
 	int do_check;
 
 	/*


