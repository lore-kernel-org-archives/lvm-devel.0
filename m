From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:21 +0000 (UTC)
Subject: master - tests: link some new cache profiles
Message-ID: <20150812124121.414EE60072@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e3ef2809a83c55131932cbd33b8de0138b590b4
Commit:        9e3ef2809a83c55131932cbd33b8de0138b590b4
Parent:        48ed8ac50cd0c384c3ff4e5e7dbc79b8f1c24cef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 20 11:56:11 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:33:16 2015 +0200

tests: link some new cache profiles

---
 test/Makefile.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 65ba294..2119509 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -199,7 +199,8 @@ install: .tests-stamp lib/paths-installed
 	$(INSTALL_PROGRAM) api/*.{t,py} $(DATADIR)/api/
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
 	$(INSTALL_DATA) $(LIB_FLAVOURS) $(DATADIR)/lib/
-	$(INSTALL_DATA) $(abs_top_srcdir)/conf/thin-performance.profile $(DATADIR)/lib/thin-performance.profile
+	for i in cache-mq cache-smq thin-performance ; do \
+		$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib/$$i.profile; done
 	$(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib/
 	for i in $(CMDS); do (cd $(DATADIR)/lib && $(LN_S) -f lvm-wrapper $$i); done
 


