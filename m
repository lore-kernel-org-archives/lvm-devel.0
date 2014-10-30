From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:41 +0000 (UTC)
Subject: master - lvmcmdline: extra support for decimal point
Message-ID: <20141030230041.12E45607B8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=519fbe71e46c747a254bc200ea93396591e1a1a3
Commit:        519fbe71e46c747a254bc200ea93396591e1a1a3
Parent:        97cccfbf1c000e597cf751e26284614a15f77cb5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 28 11:20:33 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

lvmcmdline: extra support for decimal point

If root has locales with different decimal point then '.'
(i.e. Czech with ',') lets be tolerant and retry with
"C" locales in the case '.' is found during parse of number.

Locales are then restored back.
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e59e0f4..a8ea15f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Add extra support for '.' as decimal point in size args.
   Configurable support for creation of sparse volumes with thin-pools.
   Update and correct lvcreate and lvcovert man pages.
   Mark pools and snapshots as unzeroable volumes.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c426873..33c0045 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -27,6 +27,7 @@
 #include <sys/resource.h>
 #include <dirent.h>
 #include <paths.h>
+#include <locale.h>
 
 #ifdef HAVE_GETOPTLONG
 #  include <getopt.h>
@@ -414,6 +415,17 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)), struct arg
 
 	v = strtod(val, &ptr);
 
+	if (*ptr == '.') {
+		/*
+		 * Maybe user has non-C locale with different decimal point ?
+		 * Lets be toleran and retry with standard C locales
+		 */
+		if (setlocale(LC_ALL, "C")) {
+			v = strtod(val, &ptr);
+			setlocale(LC_ALL, "");
+		}
+	}
+
 	if (ptr == val)
 		return 0;
 


