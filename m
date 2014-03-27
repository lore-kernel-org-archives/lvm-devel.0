From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 23:41:34 +0000 (UTC)
Subject: master - tests: support invalid and fail results
Message-ID: <20140327234134.08D6E608FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b44a036b147f8661567fc165e4a7de734a539b9
Commit:        5b44a036b147f8661567fc165e4a7de734a539b9
Parent:        0e02551f041ee59baeed032cccea15330ee24669
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 28 00:34:04 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 28 00:41:19 2014 +0100

tests: support invalid and fail results

Allow more detailed check for failing exit code:

invalid  -  expects 3
fail - expects 5
---
 test/Makefile.in |    9 ++++++++-
 test/lib/not.c   |    8 ++++++++
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 15cdf7e..fe33949 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -123,6 +123,13 @@ endif
 lib/should: lib/not
 	ln -sf not lib/should
 
+lib/invalid: lib/not
+	ln -sf not lib/invalid
+
+lib/fail: lib/not
+	ln -sf not lib/fail
+
+
 lib/%: lib/%.o .lib-dir-stamp
 	$(CC) $(LDFLAGS) -o $@ $<
 
@@ -144,7 +151,7 @@ lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp
 	echo 'export CLVMD_PIDFILE="@CLVMD_PIDFILE@"' >> $@-t
 	mv $@-t $@
 
-LIB = lib/not lib/should lib/harness \
+LIB = lib/not lib/invalid lib/fail lib/should lib/harness \
       lib/check lib/aux lib/test lib/utils lib/get lib/lvm-wrapper \
       lib/paths
 
diff --git a/test/lib/not.c b/test/lib/not.c
index 9f6b988..1cb12f9 100644
--- a/test/lib/not.c
+++ b/test/lib/not.c
@@ -26,6 +26,14 @@ static int finished(const char *cmd, int status) {
 		if (status)
 			fprintf(stderr, "TEST WARNING: Ignoring command failure.\n");
 		return 0;
+	} else if (!strcmp(cmd, "invalid")) {
+		if (status == 3)
+			return 0;
+		fprintf(stderr, "Test expected exit code 3 (invalid), but got %d.\n", status);
+	} else if (!strcmp(cmd, "fail")) {
+		if (status == 5)
+			return 0;
+		fprintf(stderr, "Test expected exit code 5 (fail), but got %d.\n", status);
 	}
 	return 6;
 }


