From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 11:21:43 +0000 (UTC)
Subject: master - make: use lvmconfig ... --withspaces when generating lvm.conf and lvmlocal.conf
Message-ID: <20150624112143.747CE6098F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7559d871fb9b8001a22493f2d18bcc2a9205656d
Commit:        7559d871fb9b8001a22493f2d18bcc2a9205656d
Parent:        a4724350e4909dd1b74231f22c41434dbe02c14d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 24 13:18:50 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 13:20:38 2015 +0200

make: use lvmconfig ... --withspaces when generating lvm.conf and lvmlocal.conf

---
 conf/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/Makefile.in b/conf/Makefile.in
index c98be88..43d5f75 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -27,8 +27,8 @@ include $(top_builddir)/make.tmpl
 .PHONY: install_conf install_localconf install_profiles
 
 generate:
-	(cat $(top_srcdir)/conf/example.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withcomments --ignorelocal) > example.conf.in
-	(cat $(top_srcdir)/conf/lvmlocal.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withcomments local) > lvmlocal.conf.in
+	(cat $(top_srcdir)/conf/example.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withcomments --ignorelocal --withspaces) > example.conf.in
+	(cat $(top_srcdir)/conf/lvmlocal.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withcomments --withspaces local) > lvmlocal.conf.in
 
 install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \


