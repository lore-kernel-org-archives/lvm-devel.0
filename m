From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:20:44 -0500
Subject: master - Revert "cov: avoid passing NULL to strstr function"
Message-ID: <12129.119112712204000475@us-mta-74.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=657d42e87953adcecc37701ee4e04287c30eec96
Commit:        657d42e87953adcecc37701ee4e04287c30eec96
Parent:        595aa1d4526185e0fe52430ce019a07103014b0c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 14 12:31:28 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:32 2019 -0600

Revert "cov: avoid passing NULL to strstr function"

This reverts commit 0bad3977df40a70c68778ff0514d0ca712fee402.

fixes folded into subsequent pvck commit
---
 tools/pvck.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 9f030c1..90bcafe 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -417,11 +417,11 @@ static int _dump_all_text(struct cmd_context *cmd, const char *tofile, struct de
 				memset(line, 0, sizeof(line));
 				_copy_line(str1, line, &len);
 				log_print("%s", line);
-				if ((str2 = strstr(str1, "creation_time = "))) {
-					memset(line, 0, sizeof(line));
-					_copy_line(str2, line, &len);
-					log_print("%s\n", line);
-				}
+			}
+			if ((str2 = strstr(str1, "creation_time = "))) {
+				memset(line, 0, sizeof(line));
+				_copy_line(str2, line, &len);
+				log_print("%s\n", line);
 			}
 		}
 



