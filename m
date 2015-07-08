From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Jul 2015 13:43:09 +0000 (UTC)
Subject: master - coverity: fix regresions from 16e9b32c2f1
Message-ID: <20150708134309.0AFC3617CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd37eeddd6b3901da806d536f44d43070e4fb660
Commit:        fd37eeddd6b3901da806d536f44d43070e4fb660
Parent:        6b48233f2548621c42129b8f0e2911e05c206660
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 8 15:35:37 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 8 15:41:48 2015 +0200

coverity: fix regresions from 16e9b32c2f1

16e9b32c2f1a2d7e0f05a88981824ef0e7607965 incorrectly moved
free of opened descriptor out of if{} - resulted of
closing random file handle.
---
 lib/log/log.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index e3570d4..a439d1d 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -101,10 +101,11 @@ void init_log_file(const char *log_file, int append)
 				append = 1; /* force */
 			}
 		}
+
+		if (st && fclose(st))
+			log_sys_debug("fclose", statfile);
 	}
 
-	if (st && fclose(st))
-		log_sys_debug("fclose", statfile);
 no_epoch:
 	if (!(_log_file = fopen(log_file, append ? "a" : "w"))) {
 		log_sys_error("fopen", log_file);


