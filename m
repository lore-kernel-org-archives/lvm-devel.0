From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 May 2016 07:14:36 +0000 (UTC)
Subject: master - tests: add dmstats to CLEAN_TARGETS for make clean
Message-ID: <20160531071436.3D8A76052C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cfe7d2368cfaf9744e4fc82d781b3815b5c57155
Commit:        cfe7d2368cfaf9744e4fc82d781b3815b5c57155
Parent:        4fb224a5532defa08d48b28add98606803035b9d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 31 09:14:23 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 31 09:14:23 2016 +0200

tests: add dmstats to CLEAN_TARGETS for make clean

---
 test/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 0903b90..59fcc96 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -332,7 +332,7 @@ CLEAN_TARGETS += $(RUN_BASE) $(addprefix lib/,$(LIB_LVMLOCKD_CONF))
 endif
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
-	$(CMDS) clvmd dmeventd dmsetup lvmetad lvmpolld \
+	$(CMDS) clvmd dmeventd dmsetup dmstats lvmetad lvmpolld \
 	harness thin-performance.profile fsadm vgimportclone \
 	dm-version-expected version-expected \
 	paths-installed paths-installed-t paths-common paths-common-t)


