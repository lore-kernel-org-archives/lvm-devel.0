From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:49 -0400
Subject: master - lvmcmdline: enhance acceptance of size numbers
Message-ID: <201707171140.v6HBenGk022605@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b4b5d449ef7045d33b8d8d7e69011d16f4bb8ab
Commit:        9b4b5d449ef7045d33b8d8d7e69011d16f4bb8ab
Parent:        f7e62bc55ccc7ab012325ba2ecc4a2009339989a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 10:30:07 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:32:18 2017 +0200

lvmcmdline: enhance acceptance of size numbers

Explictely detect duplicate sing symbols and leave the rest of
double number validation on 'strtod()' function. This way
we can also accept size like:

lvcreate -L.1M

We already accept -L0.1M - but it's common to accept numbers
starting with leading '.' - just as 'strtod()' accepts it).
---
 tools/lvmcmdline.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9cf2144..3ff0d1d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -560,8 +560,10 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 		av->sign = SIGN_NONE;
 	}
 
-	if (!isdigit(*val))
+	if (*val == '+' || *val == '-') {
+		log_error("Multiple sign symbols detected.");
 		return 0;
+	}
 
 	errno = 0;
 	v = strtod(val, &ptr);
@@ -596,6 +598,7 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 				break;
 
 		if (i < 0) {
+			log_error("Can't parse size argument.");
 			return 0;
 		} else if (i == 7) {
 			/* v is already in sectors */


