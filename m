From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon,  8 Mar 2021 13:12:33 +0000 (GMT)
Subject: main - makefiles: make rpm respect --disable-silent-rules
Message-ID: <20210308131233.63320394EC2D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7df4a13282a32029ab51b01d0ace14c296c0e8e3
Commit:        7df4a13282a32029ab51b01d0ace14c296c0e8e3
Parent:        e10633394d64d5a1d2434fb0166689bbfb732bef
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Mar 8 14:10:17 2021 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Mar 8 14:10:17 2021 +0100

makefiles: make rpm respect --disable-silent-rules

---
 Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Makefile.in b/Makefile.in
index 6bc3a9414..c0915fac7 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -121,7 +121,7 @@ rpm: dist
 	    -e "s,^\(Version:[^0-9%]*\)[0-9.]*$$,\1 $(LVM_VER)," \
 	    -e "s,^\(Release:[^0-9%]*\)[0-9.]\+,\1 $$GIT_VER," \
 	    $(top_srcdir)/spec/source.inc >$(rpmbuilddir)/SOURCES/source.inc
-	rpmbuild -v --define "_topdir $(rpmbuilddir)" -ba $(top_srcdir)/spec/lvm2.spec
+	V=$(V) rpmbuild -v --define "_topdir $(rpmbuilddir)" -ba $(top_srcdir)/spec/lvm2.spec
 
 generate: conf.generate man.generate
 	$(MAKE) -C conf generate


