From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Apr 2015 12:03:26 +0000 (UTC)
Subject: master - conf: Avoid temp files when generating config.
Message-ID: <20150428120326.2D4D960921@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0c46c9ed5247732e46fcb9ca4ad5be9f77a64a0
Commit:        d0c46c9ed5247732e46fcb9ca4ad5be9f77a64a0
Parent:        71dbfd7c2077fc5d83eac37da68b55ef1a195d29
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Apr 28 13:02:19 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Apr 28 13:02:19 2015 +0100

conf: Avoid temp files when generating config.

---
 conf/Makefile.in |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/conf/Makefile.in b/conf/Makefile.in
index ee78f6a..c427a2e 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -27,12 +27,8 @@ include $(top_builddir)/make.tmpl
 .PHONY: install_conf install_localconf install_profiles
 
 generate:
-	LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments --ignorelocal > example.conf.gen
-	cat example.conf.base example.conf.gen > example.conf.in
-	$(RM) example.conf.gen
-	LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments local > lvmlocal.conf.gen
-	cat lvmlocal.conf.base lvmlocal.conf.gen > lvmlocal.conf.in
-	$(RM) lvmlocal.conf.gen
+	(cat $(top_srcdir)/conf/example.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments --ignorelocal) > example.conf.in
+	(cat $(top_srcdir)/conf/lvmlocal.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments local) > lvmlocal.conf.in
 
 install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
@@ -54,4 +50,4 @@ install_lvm2: install_conf install_localconf install_profiles
 
 install: install_lvm2
 
-DISTCLEAN_TARGETS += $(CONFSRC) $(CONFLOCAL) $(PROFILE_TEMPLATES) $(CONFSRC).gen $(CONFLOCAL).gen
+DISTCLEAN_TARGETS += $(CONFSRC) $(CONFLOCAL) $(PROFILE_TEMPLATES)


