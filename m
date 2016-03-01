From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Mar 2016 16:22:06 +0000 (UTC)
Subject: master - makefile: handle dm-version-expected
Message-ID: <20160301162206.36D8860BDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=058eb3739d6f0550f81fb9d6268feda698fdbb05
Commit:        058eb3739d6f0550f81fb9d6268feda698fdbb05
Parent:        3b93c110303de10464ad3e2a4b14175526765832
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 1 16:03:02 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 1 16:03:02 2016 +0100

makefile: handle dm-version-expected

---
 test/Makefile.in |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 77190b3..f1fad14 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -209,7 +209,9 @@ install: .tests-stamp lib/paths-installed
 	cd lib && $(INSTALL_DATA) \
 		$(LIB_FLAVOURS) \
 		$(LIB_LVMLOCKD_CONF) \
-		version-expected $(DATADIR)/lib
+		dm-version-expected \
+		version-expected \
+		$(DATADIR)/lib
 	@for i in cache-mq cache-smq thin-performance ; do \
 		echo "$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib"; \
 		$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib; done
@@ -327,7 +329,8 @@ endif
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
 	$(CMDS) clvmd dmeventd dmsetup lvmetad lvmpolld \
-	harness thin-performance.profile fsadm vgimportclone version-expected \
+	harness thin-performance.profile fsadm vgimportclone \
+	dm-version-expected version-expected \
 	paths-installed paths-installed-t paths-common paths-common-t)
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status


