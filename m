From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Feb 2015 14:42:24 +0000 (UTC)
Subject: master - valgrind: when executed within valrind skip close
Message-ID: <20150212144224.6891660DBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77ceb3ee471075ce55f723a2efffb4465510ea88
Commit:        77ceb3ee471075ce55f723a2efffb4465510ea88
Parent:        9809038b9d3beddd90cb80311c61fd67856e0728
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 12 15:32:30 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 12 15:40:54 2015 +0100

valgrind: when executed within valrind skip close

Since valgrind uses internal file descriptors for communication,
don't try to close them in this case.
---
 tools/Makefile.in  |    1 +
 tools/lvmcmdline.c |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 1a8db36..6171322 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -133,6 +133,7 @@ dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
 all: device-mapper
 
 CFLAGS_lvm.o += $(EXTRA_EXEC_CFLAGS)
+CFLAGS_lvmcmdline.o += $(VALGRIND_CFLAGS)
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 1cdc293..e586777 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -29,6 +29,10 @@
 #include <paths.h>
 #include <locale.h>
 
+#ifdef HAVE_VALGRIND
+#include <valgrind.h>
+#endif
+
 #ifdef HAVE_GETOPTLONG
 #  include <getopt.h>
 #  define GETOPTLONG_FN(a, b, c, d, e) getopt_long((a), (b), (c), (d), (e))
@@ -1681,6 +1685,13 @@ static int _close_stray_fds(const char *command)
 	struct dirent *dirent;
 	DIR *d;
 
+#ifdef HAVE_VALGRIND
+	if (RUNNING_ON_VALGRIND) {
+		log_debug("Skipping close of descriptors within valgrind execution.");
+		return 1;
+	}
+#endif
+
 	if (getenv("LVM_SUPPRESS_FD_WARNINGS"))
 		suppress_warnings = 1;
 


