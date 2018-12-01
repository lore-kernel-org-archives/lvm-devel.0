From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 19:08:09 -0500
Subject: master - gcc: avoid shadowing use_aio
Message-ID: <201812010008.wB1089Op031236@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d8ad73e9377adea67819db083d66debc39dec993
Commit:        d8ad73e9377adea67819db083d66debc39dec993
Parent:        0d61a171520beeff0bf592458359d04257e2c780
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 21:56:16 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 1 01:07:01 2018 +0100

gcc: avoid shadowing use_aio

Function use_aio() is already declared, avoid its shadowing.
lvm-globals.h:59: warning: shadowed declaration is here
---
 lib/misc/lvm-globals.c |    4 ++--
 lib/misc/lvm-globals.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 0ad60fd..9d169e7 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -70,9 +70,9 @@ void init_test(int level)
 	_test = level;
 }
 
-void init_use_aio(int use_aio)
+void init_use_aio(int useaio)
 {
-	_use_aio = use_aio;
+	_use_aio = useaio;
 }
 
 void init_md_filtering(int level)
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 42dcc34..793beca 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -25,7 +25,7 @@ enum dev_ext_e;
 void init_verbose(int level);
 void init_silent(int silent);
 void init_test(int level);
-void init_use_aio(int use_aio);
+void init_use_aio(int useaio);
 void init_md_filtering(int level);
 void init_internal_filtering(int level);
 void init_fwraid_filtering(int level);


