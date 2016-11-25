From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 25 Nov 2016 23:23:19 +0000 (UTC)
Subject: master - makefiles: drop file source and indent
Message-ID: <20161125232319.59DC260CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a59cfaa1d4ffbaa46a762422b5439e9f7ce476a
Commit:        4a59cfaa1d4ffbaa46a762422b5439e9f7ce476a
Parent:        b7cf7b1d3a81749811bc33e1c0840e8f608af991
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 25 21:41:43 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 26 00:22:38 2016 +0100

makefiles: drop file source and indent

---
 daemons/Makefile.in          |    4 ++--
 daemons/lvmdbusd/Makefile.in |    1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index 2d43278..507855c 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -41,11 +41,11 @@ ifeq ("@BUILD_LVMPOLLD@", "yes")
 endif
 
 ifeq ("@BUILD_LVMLOCKD@", "yes")
-  SUBDIRS += lvmlockd 
+  SUBDIRS += lvmlockd
 endif
 
 ifeq ("@BUILD_LVMDBUSD@", "yes")
-  SUBDIRS += lvmdbusd 
+  SUBDIRS += lvmdbusd
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index c781452..0d52406 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -33,7 +33,6 @@ LVMDBUS_SRCDIR_FILES = \
 	manager.py \
 	objectmanager.py \
 	pv.py \
-	refresh.py \
 	request.py \
 	state.py \
 	udevwatch.py \


