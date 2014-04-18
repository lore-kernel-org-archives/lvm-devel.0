From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:04 +0000 (UTC)
Subject: master - makefiles: wait till include is populated
Message-ID: <20140418145504.7162660758@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4955dae4be6ca42f3428ca4f71ba86c3d0fb89b4
Commit:        4955dae4be6ca42f3428ca4f71ba86c3d0fb89b4
Parent:        db0045dfc9403f1276682831ecbd4b83e2f72ebc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 16 11:58:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:48 2014 +0200

makefiles: wait till include is populated

Since libdaemon needs configure.h header, wait forl links.
---
 Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index d248a0e..641b833 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -51,6 +51,7 @@ DISTCLEAN_TARGETS += config.cache config.log config.status make.tmpl
 include make.tmpl
 
 libdm: include
+libdaemon: include
 lib: libdm libdaemon
 liblvm: lib
 daemons: lib libdaemon tools


