From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  1 Apr 2014 13:27:09 +0000 (UTC)
Subject: master - libdm: Add missing UDEV_CFLAGS.
Message-ID: <20140401132709.B6C6D6105F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af73a0a5189c7d6abf6798952224dfe1b93d00d1
Commit:        af73a0a5189c7d6abf6798952224dfe1b93d00d1
Parent:        d5682ccbaca1e6c405494b2b84417131c7b034f5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Apr 1 15:22:37 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Apr 1 15:26:26 2014 +0200

libdm: Add missing UDEV_CFLAGS.

---
 libdm/Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 2aa70d4..e50b174 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -37,6 +37,7 @@ INCLUDES = -I$(srcdir)/$(interface) -I$(srcdir)
 ifeq ("@VALGRIND_POOL@", "yes")
 INCLUDES += @VALGRIND_CFLAGS@
 endif
+CFLAGS += $(UDEV_CFLAGS)
 
 ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(interface)/libdevmapper.a


