From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:18 +0000 (GMT)
Subject: main - makefiles: sed
Message-ID: <20210302215818.D1CCA3834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e080e35c839ab7c166acfc40b03beb7c1c1b2e56
Commit:        e080e35c839ab7c166acfc40b03beb7c1c1b2e56
Parent:        520bd9356e9ecccfa824ca639c468fdcaf3b34c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 2 21:21:38 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: sed

---
 Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Makefile.in b/Makefile.in
index a4278cade..6bc3a9414 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -117,7 +117,7 @@ rpm: dist
 	$(LN_S) -f $(abs_top_srcdir)/spec/packages.inc $(rpmbuilddir)/SOURCES
 	DM_VER=$$(cut -d- -f1 $(top_srcdir)/VERSION_DM);\
 	GIT_VER=$$(cd $(top_srcdir); git describe | cut -d- --output-delimiter=. -f2,3 || echo 0);\
-	sed -e "s,\(device_mapper_version\) [0-9.]*$$,\1 $$DM_VER," \
+	$(SED) -e "s,\(device_mapper_version\) [0-9.]*$$,\1 $$DM_VER," \
 	    -e "s,^\(Version:[^0-9%]*\)[0-9.]*$$,\1 $(LVM_VER)," \
 	    -e "s,^\(Release:[^0-9%]*\)[0-9.]\+,\1 $$GIT_VER," \
 	    $(top_srcdir)/spec/source.inc >$(rpmbuilddir)/SOURCES/source.inc


