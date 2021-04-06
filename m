From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:30 +0000 (GMT)
Subject: main - makefiles: cscope only predefined dirs
Message-ID: <20210406200730.C2CF23858012@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9452e62efb28acdadc916c00d39e7cd615d5c953
Commit:        9452e62efb28acdadc916c00d39e7cd615d5c953
Parent:        f1bfc0621b9d86349a1878c1e64e96c5c7040786
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 4 11:25:54 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 22:02:31 2021 +0200

makefiles: cscope only predefined dirs

Avoid scanning for source duplicates in various build dirs.
---
 Makefile.in | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Makefile.in b/Makefile.in
index c0915fac7..69c73598e 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -83,8 +83,9 @@ cflow: include.cflow
 endif
 
 ifneq ("@CSCOPE_CMD@", "")
+CSCOPE_DIRS = base daemons device_mapper include lib libdaemon scripts tools
 cscope.out:
-	@CSCOPE_CMD@ -b -R -s$(top_srcdir)
+	@CSCOPE_CMD@ -b -R $(patsubst %,-s%,$(addprefix $(srcdir)/,$(CSCOPE_DIRS)))
 all: cscope.out
 endif
 DISTCLEAN_TARGETS += cscope.out


