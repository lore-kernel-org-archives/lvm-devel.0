From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 08:48:06 +0000 (GMT)
Subject: main - makefiles: add devmapper for devmapper-event
Message-ID: <20210412084806.895D03835429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=31410447fd5719368baf07ba34004330958fbcf1
Commit:        31410447fd5719368baf07ba34004330958fbcf1
Parent:        a5f83cb612497c76a5a0e9a69cddea531af4688f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 12 10:35:55 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 10:35:55 2021 +0200

makefiles: add devmapper  for devmapper-event

Older linkers do not take this dependency automatically from
libdevmapper-event so need to be passed with linker command.
---
 make.tmpl.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 6145b0bd5..200ea2e05 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -269,7 +269,7 @@ endif
 endif
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
-  DMEVENT_LIBS = -ldevmapper-event
+  DMEVENT_LIBS = -ldevmapper-event -L$(interfacebuilddir) -ldevmapper
   LDFLAGS += -L$(top_builddir)/daemons/dmeventd
   CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
 endif


