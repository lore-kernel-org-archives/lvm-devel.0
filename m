From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  2 Oct 2014 07:31:12 +0000 (UTC)
Subject: master - cleanup: remove symlink to profile in test dir for CLEAN target
Message-ID: <20141002073112.C430460EC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3fb69c3f39df1a60fa05ed25a7d270af996054d
Commit:        d3fb69c3f39df1a60fa05ed25a7d270af996054d
Parent:        1cdb8766a7cf500b6657cf6f6baf2d785a3708f5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 2 09:30:38 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 2 09:30:38 2014 +0200

cleanup: remove symlink to profile in test dir for CLEAN target

---
 test/Makefile.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 46aeaec..9774f6c 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -189,7 +189,8 @@ clean:
 	$(RM) -r $(LVM_TEST_RESULTS)
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,$(CMDS)) \
-	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone
+	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone \
+	lib/thin-performance.profile
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@


