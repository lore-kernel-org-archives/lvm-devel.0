From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:25 -0500
Subject: master - cov: avoid passing NULL to strstr function
Message-ID: <64633.119111412072302373@us-mta-225.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0bad3977df40a70c68778ff0514d0ca712fee402
Commit:        0bad3977df40a70c68778ff0514d0ca712fee402
Parent:        153e55c20e9a3810a1862314a6465179e1b53931
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:13:02 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

cov: avoid passing NULL to strstr function

When 'str1' would be NULL, there is no point to run 2nd. strstr().
---
 tools/pvck.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 79fb8fb..1c1bbc2 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -420,11 +420,11 @@ static int _dump_all_text(struct cmd_context *cmd, const char *tofile, struct de
 				memset(line, 0, sizeof(line));
 				_copy_line(str1, line, &len);
 				log_print("%s", line);
-			}
-			if ((str2 = strstr(str1, "creation_time = "))) {
-				memset(line, 0, sizeof(line));
-				_copy_line(str2, line, &len);
-				log_print("%s\n", line);
+				if ((str2 = strstr(str1, "creation_time = "))) {
+					memset(line, 0, sizeof(line));
+					_copy_line(str2, line, &len);
+					log_print("%s\n", line);
+				}
 			}
 		}
 



