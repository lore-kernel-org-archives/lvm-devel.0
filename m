From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 14:57:20 -0400
Subject: master - lvmcmdline: restore digit check
Message-ID: <201707171857.v6HIvKZW030334@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=864017710c65e07a19d70bc226b2522a6b1907dc
Commit:        864017710c65e07a19d70bc226b2522a6b1907dc
Parent:        fde23f7ce1a7e567fce3f1d33387f110f81d1fef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 17 20:36:39 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 20:54:42 2017 +0200

lvmcmdline: restore digit check

Commit 9b4b5d449ef7045d33b8d8d7e69011d16f4bb8ab started to accept
rather way to wide set of strings we do not want to take for size.
i.e.  lvresize -t vg0/lvol0 -LNaNM

Restore check for 'digit ||  locales defined 'dot' |  '.'
(as we tend to take '.' even if locales uses ',')
---
 tools/lvmcmdline.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3ff0d1d..c62c776 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -32,6 +32,7 @@
 #include <dirent.h>
 #include <paths.h>
 #include <locale.h>
+#include <langinfo.h>
 
 #ifdef HAVE_VALGRIND
 #include <valgrind.h>
@@ -543,6 +544,7 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 	char *val;
 	double v;
 	uint64_t v_tmp, adjustment;
+	char *radixchar = nl_langinfo(RADIXCHAR);
 
 	av->percent = PERCENT_NONE;
 
@@ -565,6 +567,14 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 		return 0;
 	}
 
+
+	if (!isdigit(*val) &&
+	    (*val != '.') &&
+	    (radixchar && (*val != radixchar[0]))) {
+		log_error("Size requires number argument.");
+		return 0;
+	}
+
 	errno = 0;
 	v = strtod(val, &ptr);
 


