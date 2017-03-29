From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 29 Mar 2017 18:39:23 -0400
Subject: master - man: fix type
Message-ID: <201703292239.v2TMdNIm016004@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a66411bd7acd129a61f6b3dde4c8ac448e27e4c7
Commit:        a66411bd7acd129a61f6b3dde4c8ac448e27e4c7
Parent:        dfdd6ccf3be73a2b22743ea1df31cd3d7e3c9095
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 30 00:35:46 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 30 00:38:41 2017 +0200

man: fix type

With commit 4af09a94bd44693e5a40a4f895599601d8233d69 unwanted rename  of
target happened - restore it.
---
 man/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 2421116..dd170ac 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -260,7 +260,7 @@ install_device-mapper: $(MAN8DM)
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8DM) $(MAN8DIR)/
 
-install_systemdgenerators: $(MAN8SYSTEMD_GENERATORS)
+install_systemd_generators: $(MAN8SYSTEMD_GENERATORS)
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8SYSTEMD_GENERATORS) $(MAN8DIR)/
 


