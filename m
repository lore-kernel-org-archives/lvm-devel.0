From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:32 +0000 (UTC)
Subject: master - makefiles: drop explicit linking
Message-ID: <20151013140432.BF9F961175@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83f00e91567d387caf02da9cd3791c3fef85c80d
Commit:        83f00e91567d387caf02da9cd3791c3fef85c80d
Parent:        4f9e7f692ea1dc6370ee9978b34c4255d28b3c3c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 9 21:33:59 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:02:20 2015 +0200

makefiles: drop explicit linking

Nothing in /sscripts needs devmapper-event library so drop its linking.
---
 scripts/Makefile.in |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index dabe2ee..f7f672d 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -28,11 +28,6 @@ ifeq ("@APPLIB@", "yes")
 	LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 endif
 
-ifeq ("@DMEVENTD@", "yes")
-	DEPLIBS += $(top_builddir)/daemons/dmeventd/libdevmapper-event.so
-	LVMLIBS += -ldevmapper-event
-endif
-
 LVM_SCRIPTS = lvmdump.sh lvmconf.sh vgimportclone.sh
 DM_SCRIPTS =
 


