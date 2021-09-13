From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:12 +0000 (GMT)
Subject: main - cov: keep time calculation ready for 2038
Message-ID: <20210913103612.9D8C83858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=be1c2a1ae2da445309f04ac4e3ed7470ff29d436
Commit:        be1c2a1ae2da445309f04ac4e3ed7470ff29d436
Parent:        3ce8db8b889cbebdfe13aa394f5b6a9a9d00e25c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 9 22:37:36 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cov: keep time calculation ready for 2038

Be prepared ;) and keep arithmetic 64bit ready.
---
 lib/report/report.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 0fd0f30ac..efe103f43 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -819,7 +819,7 @@ static void _adjust_time_for_granularity(struct time_info *info, struct tm *tm,
 
 #define SECS_PER_MINUTE 60
 #define SECS_PER_HOUR   3600
-#define SECS_PER_DAY    86400
+#define SECS_PER_DAY    ((time_t)86400)
 
 static int _days_in_month[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
 


