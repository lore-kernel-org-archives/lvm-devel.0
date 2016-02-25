From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 25 Feb 2016 16:51:50 +0000 (UTC)
Subject: master - tests: make lib/expected-version-dm a dependency of .tests-stamp
Message-ID: <20160225165150.4529260204@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11fd7b7c645c0462cac95687c098019cf779cd58
Commit:        11fd7b7c645c0462cac95687c098019cf779cd58
Parent:        d4a5c252c59fb22d705fc0978ccf0d7cf2a69ba7
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Dec 11 13:18:40 2015 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Feb 25 16:40:59 2016 +0000

tests: make lib/expected-version-dm a dependency of .tests-stamp

---
 test/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index fdae254..77190b3 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -294,7 +294,7 @@ lib/dm-version-expected: $(top_srcdir)/VERSION_DM .lib-dir-stamp
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
 LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 
-.tests-stamp: $(ALL) $(LIB) $(SUBDIRS) lib/version-expected
+.tests-stamp: $(ALL) $(LIB) $(SUBDIRS) lib/version-expected lib/dm-version-expected
 	@if test "$(srcdir)" != . ; then \
 		echo "Linking tests to builddir."; \
 		$(MKDIR_P) shell; \


