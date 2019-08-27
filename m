From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 27 Aug 2019 06:23:29 -0400
Subject: stable-2.02 - build: Fix make rpm with releases
Message-ID: <201908271023.x7RANTPZ013904@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e4f72e6655ff756c886ad78abcc696d3267e6c5f
Commit:        e4f72e6655ff756c886ad78abcc696d3267e6c5f
Parent:        8bcd482cc5fc58c9d5ff5305f1f1bff5d80eaa92
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 2 15:18:40 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Aug 27 12:23:13 2019 +0200

build: Fix make rpm with releases

- git describe returns just v2_02_182 instead of e.g.
  v2_02_181-44-adf123, so cut needs -s option.

- there is no dash in VERSION_DM so we need to split on space first.
---
 Makefile.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index e2f5a84..29d5bed 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -124,11 +124,11 @@ rpm: dist
 	$(LN_S) -f $(abs_top_srcdir)/spec/build.inc $(rpmbuilddir)/SOURCES
 	$(LN_S) -f $(abs_top_srcdir)/spec/macros.inc $(rpmbuilddir)/SOURCES
 	$(LN_S) -f $(abs_top_srcdir)/spec/packages.inc $(rpmbuilddir)/SOURCES
-	DM_VER=$$(cut -d- -f1 $(top_srcdir)/VERSION_DM);\
-	GIT_VER=$$(cd $(top_srcdir); git describe | cut -d- --output-delimiter=. -f2,3 || echo 0);\
+	DM_VER=$$(cut -d' ' -f1 $(top_srcdir)/VERSION_DM | cut -d- -f1);\
+	GIT_VER=$$(cd $(top_srcdir); git describe | cut -s -d- --output-delimiter=. -f2,3);\
 	sed -e "s,\(device_mapper_version\) [0-9.]*$$,\1 $$DM_VER," \
 	    -e "s,^\(Version:[^0-9%]*\)[0-9.]*$$,\1 $(LVM_VER)," \
-	    -e "s,^\(Release:[^0-9%]*\)[0-9.]\+,\1 $$GIT_VER," \
+	    -e "s,^\(Release:[^0-9%]*\)[0-9.]\+,\1 $${GIT_VER:-"0"}," \
 	    $(top_srcdir)/spec/source.inc >$(rpmbuilddir)/SOURCES/source.inc
 	rpmbuild -v --define "_topdir $(rpmbuilddir)" -ba $(top_srcdir)/spec/lvm2.spec
 


