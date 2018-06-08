From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:38:53 -0400
Subject: master - build: drop exported symbols
Message-ID: <201806081238.w58Ccr0J006060@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc8c8d2f87a93a5f1c77a928e7400d31788fc6fd
Commit:        bc8c8d2f87a93a5f1c77a928e7400d31788fc6fd
Parent:        5cb4b2a42465f2430c98c8966adeacb0f6a26af3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 7 23:23:06 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:37:31 2018 +0200

build: drop exported symbols

This libs are no longer possible to create,
drop maintanence of exported symbols.
---
 lib/cache_segtype/.exported_symbols |    1 -
 lib/mirror/.exported_symbols        |    1 -
 lib/raid/.exported_symbols          |    1 -
 lib/snapshot/.exported_symbols      |    1 -
 lib/thin/.exported_symbols          |    1 -
 5 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/lib/cache_segtype/.exported_symbols b/lib/cache_segtype/.exported_symbols
deleted file mode 100644
index 95cb3ff..0000000
--- a/lib/cache_segtype/.exported_symbols
+++ /dev/null
@@ -1 +0,0 @@
-init_cache_segtypes
diff --git a/lib/mirror/.exported_symbols b/lib/mirror/.exported_symbols
deleted file mode 100644
index 1c92c6a..0000000
--- a/lib/mirror/.exported_symbols
+++ /dev/null
@@ -1 +0,0 @@
-init_segtype
diff --git a/lib/raid/.exported_symbols b/lib/raid/.exported_symbols
deleted file mode 100644
index 0d012d6..0000000
--- a/lib/raid/.exported_symbols
+++ /dev/null
@@ -1 +0,0 @@
-init_multiple_segtypes
diff --git a/lib/snapshot/.exported_symbols b/lib/snapshot/.exported_symbols
deleted file mode 100644
index 1c92c6a..0000000
--- a/lib/snapshot/.exported_symbols
+++ /dev/null
@@ -1 +0,0 @@
-init_segtype
diff --git a/lib/thin/.exported_symbols b/lib/thin/.exported_symbols
deleted file mode 100644
index 1c92c6a..0000000
--- a/lib/thin/.exported_symbols
+++ /dev/null
@@ -1 +0,0 @@
-init_segtype


