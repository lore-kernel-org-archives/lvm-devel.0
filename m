From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 22:19:54 +0000 (UTC)
Subject: master - makefiles: use fullpath when in assign
Message-ID: <20150513221954.103116066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8fc483ca4914ddc67b7831150f1ee4c3c429ec1
Commit:        a8fc483ca4914ddc67b7831150f1ee4c3c429ec1
Parent:        7bd1559db62ce5986da806424a193a25965f5fdc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 13 15:43:55 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 00:19:32 2015 +0200

makefiles: use fullpath when in assign

We need to put full path right in the assign moment,
otherwise command:

make rpm rpmbuild=/my/tmp/dir

cannot work as one would have expected.
---
 Makefile.in  |    3 ++-
 make.tmpl.in |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index be4241c..43a6ed0 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -93,6 +93,7 @@ cscope.out:
 all: cscope.out
 endif
 DISTCLEAN_TARGETS += cscope.out
+CLEAN_DIRS += autom4te.cache
 
 check check_system check_cluster check_local check_lvmetad unit: all
 	$(MAKE) -C test $(@)
@@ -125,7 +126,7 @@ rpm: dist
 	    -e "s,^\(Version:[^0-9%]*\)[0-9.]*$$,\1 $(LVM_VER)," \
 	    -e "s,^\(Release:[^0-9%]*\)[0-9.]\+,\1 $$GIT_VER," \
 	    $(top_srcdir)/spec/source.inc >$(rpmbuilddir)/SOURCES/source.inc
-	rpmbuild -v --define "_topdir $(abs_top_builddir)/$(rpmbuilddir)" -ba $(top_srcdir)/spec/lvm2.spec
+	rpmbuild -v --define "_topdir $(rpmbuilddir)" -ba $(top_srcdir)/spec/lvm2.spec
 
 generate: conf.generate
 	$(MAKE) -C conf generate
diff --git a/make.tmpl.in b/make.tmpl.in
index d85dd69..1aae6a2 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -116,7 +116,7 @@ vpath %.exported_symbols $(srcdir)
 
 interface = @interface@
 interfacebuilddir = $(top_builddir)/libdm/$(interface)
-rpmbuilddir = build
+rpmbuilddir = $(abs_top_builddir)/build
 
 # The number of jobs to run, if blank, defaults to the make standard
 ifndef MAKEFLAGS


