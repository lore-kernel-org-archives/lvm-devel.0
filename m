From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:25 +0000 (UTC)
Subject: master - cleanup: drop unused header
Message-ID: <20131122200925.F1D0D61097@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ebbf1982892a819dc14045a8dca0ad512cebdf8
Commit:        6ebbf1982892a819dc14045a8dca0ad512cebdf8
Parent:        07d766d270f764e3a8300fee79ac559d18f21e66
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 10:04:13 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:56 2013 +0100

cleanup: drop unused header

Header is not used here.
---
 liblvm/lvm_base.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index d694173..80a4894 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -18,7 +18,6 @@
 #include "lvm-version.h"
 #include "metadata-exported.h"
 #include "lvm2app.h"
-#include "lvm-string.h"
 
 const char *lvm_library_get_version(void)
 {


