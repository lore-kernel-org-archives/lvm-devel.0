From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 27 Jan 2023 11:36:37 +0000 (GMT)
Subject: rhel-9.2.0 - build: Fix make rpm with VERSION_DM without dash
Message-ID: <20230127113637.785803858291@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=611b768134fe39ddfb2eec99eb5417e7e001d8cd
Commit:        611b768134fe39ddfb2eec99eb5417e7e001d8cd
Parent:        0441d340e752427d0d355a85e5e5e465e911a102
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jun 15 11:53:51 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jan 27 12:36:24 2023 +0100

build: Fix make rpm with VERSION_DM without dash

When building RPM from a branch based on a release tag the expected -git
suffix is missing breaking the script producing error like following one:

    error: line 215: Unterminated rich dependency: (2021-53.ge36b180a6.el9: Requires: device-mapper-devel >= 1.02.181 (2021-53.ge36b180a6.el9

(cherry picked from commit e60d7ce8e748cb6d51552879c162d01aafa17160)
---
 Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Makefile.in b/Makefile.in
index 1d5aff482..91b21b78c 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -110,7 +110,7 @@ rpm: dist
 	$(LN_S) -f $(abs_top_srcdir)/spec/build.inc $(rpmbuilddir)/SOURCES
 	$(LN_S) -f $(abs_top_srcdir)/spec/macros.inc $(rpmbuilddir)/SOURCES
 	$(LN_S) -f $(abs_top_srcdir)/spec/packages.inc $(rpmbuilddir)/SOURCES
-	DM_VER=$$(cut -d- -f1 $(top_srcdir)/VERSION_DM);\
+	DM_VER=$$(cut -d' ' -f1 $(top_srcdir)/VERSION_DM | cut -d- -f1);\
 	GIT_VER=$$(cd $(top_srcdir); git describe | cut -d- --output-delimiter=. -f2,3 || echo 0);\
 	$(SED) -e "s,\(device_mapper_version\) [0-9.]*$$,\1 $$DM_VER," \
 	    -e "s,^\(Version:[^0-9%]*\)[0-9.]*$$,\1 $(LVM_VER)," \

