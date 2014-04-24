From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Apr 2014 17:53:19 +0000 (UTC)
Subject: master - test: Fix default.profile path.
Message-ID: <20140424175319.3F19A602EB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9676ee9ba9414c64bf9b519479f69be99e9a1dc7
Commit:        9676ee9ba9414c64bf9b519479f69be99e9a1dc7
Parent:        22037ee3289d3929b534812905b5c6d30f9ee4f8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 24 18:52:29 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 24 18:52:29 2014 +0100

test: Fix default.profile path.

It's a generated file.
---
 test/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 7253bb4..33d8ab4 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -177,7 +177,7 @@ CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
 	ln -fs $(abs_top_builddir)/daemons/lvmetad/lvmetad lib/lvmetad
 	ln -fs $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone
 	ln -fs $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
-	ln -fs $(abs_top_srcdir)/conf/default.profile lib/default.profile
+	ln -fs $(abs_top_builddir)/conf/default.profile lib/default.profile
 	ln -fs $(abs_top_srcdir)/conf/thin-performance.profile lib/thin-performance.profile
 	touch $@
 


