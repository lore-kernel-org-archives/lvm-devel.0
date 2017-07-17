From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 15:27:52 -0400
Subject: master - lvmcmdline: enhance locales check
Message-ID: <201707171927.v6HJRqsr002680@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4fa739faf2d30beea5a8423806594f506644a540
Commit:        4fa739faf2d30beea5a8423806594f506644a540
Parent:        864017710c65e07a19d70bc226b2522a6b1907dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 17 21:25:50 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 21:25:50 2017 +0200

lvmcmdline: enhance locales check

Make check for 'radixchar' more readable and logical.
Also avoid reread of number of locale is already using '.' as radixchar.
---
 tools/lvmcmdline.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c62c776..a952c8c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -544,7 +544,7 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 	char *val;
 	double v;
 	uint64_t v_tmp, adjustment;
-	char *radixchar = nl_langinfo(RADIXCHAR);
+	const char *radixchar = nl_langinfo(RADIXCHAR) ? : ".";
 
 	av->percent = PERCENT_NONE;
 
@@ -567,10 +567,7 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 		return 0;
 	}
 
-
-	if (!isdigit(*val) &&
-	    (*val != '.') &&
-	    (radixchar && (*val != radixchar[0]))) {
+	if (!isdigit(*val) && (*val != '.') && (*val != radixchar[0])) {
 		log_error("Size requires number argument.");
 		return 0;
 	}
@@ -578,10 +575,10 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 	errno = 0;
 	v = strtod(val, &ptr);
 
-	if (*ptr == '.') {
+	if (*ptr == '.' && radixchar[0] != '.') {
 		/*
 		 * Maybe user has non-C locale with different decimal point ?
-		 * Lets be toleran and retry with standard C locales
+		 * Lets be tolerant and retry with standard C locales
 		 */
 		if (setlocale(LC_ALL, "C")) {
 			errno = 0;


