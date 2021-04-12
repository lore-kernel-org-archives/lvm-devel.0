From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:40 +0000 (GMT)
Subject: main - makefiles: reuse CSCOPE_DIRS for ctags
Message-ID: <20210412075540.B890F39FCC6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2e84dd47d44a3a65a984e3af724684d4982785a3
Commit:        2e84dd47d44a3a65a984e3af724684d4982785a3
Parent:        ebf33323b93870f811c5a701826cfab1f4d41489
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 9 15:27:12 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

makefiles: reuse CSCOPE_DIRS for ctags

Create ctags only from real source files.
---
 Makefile.in | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 4dceaba1d..3b7e0ecaa 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -76,8 +76,8 @@ daemons.cflow: tools.cflow
 cflow: include.cflow
 endif
 
+CSCOPE_DIRS = base daemons device_mapper include lib libdaemon scripts tools libdm test
 ifneq ("@CSCOPE_CMD@", "")
-CSCOPE_DIRS = base daemons device_mapper include lib libdaemon scripts tools
 cscope.out:
 	@CSCOPE_CMD@ -b -R $(patsubst %,-s%,$(addprefix $(srcdir)/,$(CSCOPE_DIRS)))
 all: cscope.out
@@ -204,8 +204,8 @@ endif
 ifneq ($(shell which ctags 2>/dev/null),)
 .PHONY: tags
 tags:
-	test -z "$(shell find $(top_srcdir) -type f -name '*.[ch]' -newer tags 2>/dev/null | head -1)" || $(RM) tags
-	test -f tags || find $(top_srcdir) -maxdepth 5 -type f -name '*.[ch]' -exec ctags -a '{}' +
+	test -z "$(shell find $(addprefix $(top_srcdir)/,$(CSCOPE_DIRS)) -type f -name '*.[ch]' -newer tags 2>/dev/null | head -1)" || $(RM) tags
+	test -f tags || find $(addprefix $(top_srcdir)/,$(CSCOPE_DIRS)) -maxdepth 5 -type f -name '*.[ch]' -exec ctags -a '{}' +
 
 CLEAN_TARGETS += tags
 endif


