From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 22 Apr 2015 15:06:03 +0000 (UTC)
Subject: master - make: autoconfisms for generate
Message-ID: <20150422150603.707296148D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=33429ea0833c958f2f548c231b301243e06e81bd
Commit:        33429ea0833c958f2f548c231b301243e06e81bd
Parent:        808f88f9f0db2f744c0f2517fa4aa4f7b9c138ec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 22 10:05:02 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 22 10:05:02 2015 -0500

make: autoconfisms for generate

---
 conf/Makefile.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/conf/Makefile.in b/conf/Makefile.in
index 5e8a0b5..ee78f6a 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -29,10 +29,10 @@ include $(top_builddir)/make.tmpl
 generate:
 	LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments --ignorelocal > example.conf.gen
 	cat example.conf.base example.conf.gen > example.conf.in
-	rm example.conf.gen
+	$(RM) example.conf.gen
 	LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments local > lvmlocal.conf.gen
 	cat lvmlocal.conf.base lvmlocal.conf.gen > lvmlocal.conf.in
-	rm lvmlocal.conf.gen
+	$(RM) lvmlocal.conf.gen
 
 install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
@@ -54,4 +54,4 @@ install_lvm2: install_conf install_localconf install_profiles
 
 install: install_lvm2
 
-DISTCLEAN_TARGETS += $(CONFSRC) $(CONFLOCAL) $(PROFILE_TEMPLATES)
+DISTCLEAN_TARGETS += $(CONFSRC) $(CONFLOCAL) $(PROFILE_TEMPLATES) $(CONFSRC).gen $(CONFLOCAL).gen


