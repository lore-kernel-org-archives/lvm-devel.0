From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:02:39 -0400
Subject: master - build: ensure libdm is built before dm-tools
Message-ID: <201806142002.w5EK2dK6003505@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c6be40960917de0e3baab23ab44c64c682895049
Commit:        c6be40960917de0e3baab23ab44c64c682895049
Parent:        327f62a25533c195f4b49a29974f3c5a2f93c15b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 20:37:33 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

build: ensure libdm is built before dm-tools

Making libs before entering dm-tools subdir,
so the tool will not link i.e. system library if present.
---
 libdm/Makefile.in |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 6472da7..8c8334a 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -62,6 +62,8 @@ LIBS += $(RT_LIBS) $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS) $(M_LIBS)
 
 device-mapper: all
 
+dm-tools.device-mapper: $(TARGETS)
+
 libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION): $(LIB_SHARED)
 	$(LN_S) -f $< $@
 


