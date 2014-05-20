From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:54:03 +0000 (UTC)
Subject: master - tests: rebuild paths when Makefile is updated
Message-ID: <20140520195403.A45A560C83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08fd24450685abd935d744795a6c2fc5e819ef64
Commit:        08fd24450685abd935d744795a6c2fc5e819ef64
Parent:        2e9792121fa93e7cb67583cd2757dd52ab2825dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 21:27:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:30 2014 +0200

tests: rebuild paths when Makefile is updated

---
 test/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 33b7042..1538fa3 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -137,7 +137,7 @@ lib/%: $(srcdir)/lib/%.sh .lib-dir-stamp
 	cp $< $@
 	chmod +x $@
 
-lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp
+lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	$(RM) $@-t
 	echo 'top_srcdir="$(top_srcdir)"' >> $@-t
 	echo 'abs_top_builddir="$(abs_top_builddir)"' >> $@-t


