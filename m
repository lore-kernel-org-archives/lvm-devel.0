From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 20:04:31 +0000 (UTC)
Subject: master - makefiles: older gcc needs hint with rpath
Message-ID: <20151013200431.42ACA611A3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a91fbe9d27a79b4be7fad72fc7a1ba2a976ecd41
Commit:        a91fbe9d27a79b4be7fad72fc7a1ba2a976ecd41
Parent:        ccc39be053b9a186abc6a020f516ff5f425981d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 22:02:17 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 22:02:17 2015 +0200

makefiles: older gcc needs hint with rpath

gcc 4.3 seems not to be able to find linked library without
specifying -rpath to linker  (plain -L) is not enough.
---
 scripts/Makefile.in |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index f7f672d..bfa0fad 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -25,6 +25,9 @@ include $(top_builddir)/make.tmpl
 ifeq ("@APPLIB@", "yes")
 	DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
 	LDFLAGS += -L$(top_builddir)/liblvm
+ifeq ("@DMEVENTD@", "yes")
+	LDFLAGS += -Wl,-rpath,$(top_builddir)/daemons/dmeventd
+endif
 	LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 endif
 


