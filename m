From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 5 Jul 2019 19:26:14 -0400
Subject: stable-2.02 - gcc: cleanup warning of shawhing a global dclr
Message-ID: <201907052326.x65NQEAW009690@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9aedf68c32f5ba7217b37e466546b5abb4f33f76
Commit:        9aedf68c32f5ba7217b37e466546b5abb4f33f76
Parent:        ea036ecfd3980b88589e513e9b61efc215bce774
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 22:47:27 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jul 6 01:24:28 2019 +0200

gcc: cleanup warning of shawhing a global dclr

misc/lvm-globals.c:76: warning: declaration of ?????use_aio???????? shadows a global declaration
misc/lvm-globals.h:63: warning: shadowed declaration is here
---
 lib/misc/lvm-globals.c |    4 ++--
 lib/misc/lvm-globals.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 3bd5cac..35faf83 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -73,9 +73,9 @@ void init_test(int level)
 	_test = level;
 }
 
-void init_use_aio(int use_aio)
+void init_use_aio(int use)
 {
-	_use_aio = use_aio;
+	_use_aio = use;
 }
 
 void init_md_filtering(int level)
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 3007cc5..27d1919 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -25,7 +25,7 @@ enum dev_ext_e;
 void init_verbose(int level);
 void init_silent(int silent);
 void init_test(int level);
-void init_use_aio(int use_aio);
+void init_use_aio(int use);
 void init_md_filtering(int level);
 void init_internal_filtering(int level);
 void init_fwraid_filtering(int level);


