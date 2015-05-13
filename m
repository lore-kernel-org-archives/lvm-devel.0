From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 22:19:51 +0000 (UTC)
Subject: master - makefiles: testclient is not valid target
Message-ID: <20150513221951.F12DD60F10@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7bd1559db62ce5986da806424a193a25965f5fdc
Commit:        7bd1559db62ce5986da806424a193a25965f5fdc
Parent:        ea846f1ca2910f03d66e2859b8189a215b3d8d4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 13 14:22:46 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 00:19:32 2015 +0200

makefiles: testclient is not valid target

---
 daemons/lvmetad/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index 0a174bb..f9b997e 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -18,7 +18,7 @@ top_builddir = @top_builddir@
 SOURCES = lvmetad-core.c
 SOURCES2 = testclient.c
 
-TARGETS = lvmetad lvmetad-testclient
+TARGETS = lvmetad
 
 .PHONY: install_lvmetad
 


