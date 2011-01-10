From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jan 2011 13:25:23 -0000
Subject: LVM2/test/lib harness.c
Message-ID: <20110110132523.27769.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-10 13:25:22

Modified files:
	test/lib       : harness.c 

Log message:
	Use strndup as GNU extension
	
	strndup needs _GNU_SOURCE defined as it's GNU extension.
	Remove duplicate string.h header added in previous harness commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/lib/harness.c	2011/01/05 15:03:43	1.2
+++ LVM2/test/lib/harness.c	2011/01/10 13:25:22	1.3
@@ -12,6 +12,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#define _GNU_SOURCE
 #include <fcntl.h>
 #include <string.h>
 #include <stdio.h>
@@ -19,7 +20,6 @@
 #include <sys/wait.h>
 #include <unistd.h>
 #include <stdlib.h>
-#include <string.h>
 
 static pid_t pid;
 static int fds[2];


