From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:31 +0000 (UTC)
Subject: dev-prajnoha-report-select - cleanup: default.profile is not used (and it was split in two and renamed anyway)
Message-ID: <20140606120331.5C20E609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14f482077dadd33e35a33cbd57bc80a884992794
Commit:        14f482077dadd33e35a33cbd57bc80a884992794
Parent:        291e55557ee4061a042d6d59b04aa09e6f503386
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 6 10:24:50 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 10:24:50 2014 +0200

cleanup: default.profile is not used (and it was split in two and renamed anyway)

---
 test/Makefile.in |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 370d9bd..5ac045f 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -181,7 +181,6 @@ CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
 	ln -fs $(abs_top_builddir)/daemons/lvmetad/lvmetad lib/lvmetad
 	ln -fs $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone
 	ln -fs $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
-	ln -fs $(abs_top_builddir)/conf/default.profile lib/default.profile
 	ln -fs $(abs_top_srcdir)/conf/thin-performance.profile lib/thin-performance.profile
 	touch $@
 


