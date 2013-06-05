From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:03 +0000 (UTC)
Subject: dev-mornfall-lvmcache - cleanup: simplify
Message-ID: <20130605120303.A7A1A61447@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=deb3c93a192c5ea03434ea11d33dff571462edc3
Commit:        deb3c93a192c5ea03434ea11d33dff571462edc3
Parent:        986a50e4a1c017cc655bbcce45ffa4444386678b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 29 12:33:38 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 15:44:14 2013 +0200

cleanup: simplify

Use simplier sprintf.
---
 tools/reporter.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 3db8b83..2744fcd 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -301,9 +301,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 				log_error("options string allocation failed");
 				return ECMD_FAILED;
 			}
-			strcpy(str, options);
-			strcat(str, ",");
-			strcat(str, opts + 1);
+			(void) sprintf(str, "%s,%s", options, opts + 1);
 			options = str;
 		} else
 			options = opts;


