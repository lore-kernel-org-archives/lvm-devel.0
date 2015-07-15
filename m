From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Jul 2015 11:10:57 +0000 (UTC)
Subject: master - makefiles: adding target for generating ctags
Message-ID: <20150715111057.AC88F609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=beb65056cf450ac14c2354f87a981cd5a379560c
Commit:        beb65056cf450ac14c2354f87a981cd5a379560c
Parent:        c2d4330f27277717bc3b684b702189079b257b77
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 12:09:02 2009 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 15 13:10:22 2015 +0200

makefiles: adding target for generating ctags

make tags generates traditional tags ctags ref list.
---
 Makefile.in |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 43a6ed0..1eb026b 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -223,3 +223,13 @@ memcheck: test-programs
 ruby-test:
 	$(RUBY) report-generators/test/ts.rb
 endif
+
+ifneq ($(shell which ctags),)
+.PHONY: tags
+all: tags
+tags:
+	test -z "$(shell find $(top_srcdir) -type f -name '*.[ch]' -newer tags | head -1)" || $(RM) tags
+	test -f tags || find $(top_srcdir) -maxdepth 4 -type f -name '*.[ch]' -exec ctags -a '{}' +
+
+DISTCLEAN_TARGETS += tags
+endif


