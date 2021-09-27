From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:46 +0000 (GMT)
Subject: main - utils: define macro for ffs
Message-ID: <20210927165746.7BB043858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef21ed78ae5a3dd0b30e4b247ec3774347cadb4d
Commit:        ef21ed78ae5a3dd0b30e4b247ec3774347cadb4d
Parent:        6a186dd1e85cecac84f0bc5cc32c0e47fd33994f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 21:43:30 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

utils: define macro for ffs

Provide ffs() macro using __builtin_ffs(), when there is missing
ffs() implementation in header file.

Reported-by: adamboardman of gemian
---
 lib/misc/util.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/lib/misc/util.h b/lib/misc/util.h
index a42ecb355..35514eee0 100644
--- a/lib/misc/util.h
+++ b/lib/misc/util.h
@@ -89,6 +89,14 @@ static unsigned _dm_clzll(unsigned long long x)
 #define clzll(x) _dm_clzll((x))
 #endif /* ifdef HAVE___BUILTIN_CLZLL */
 
+#ifndef HAVE_FFS
+#ifdef HAVE___BUILTIN_FFS
+#define ffs(x) __builtin_ffs((x))
+#else
+#error ffs() not implemented!
+#endif /* ifdef HAVE___BUILTIN_FFS */
+#endif /* ifndef HAVE_FFS */
+
 #define KERNEL_VERSION(major, minor, release) (((major) << 16) + ((minor) << 8) + (release))
 
 /* Define some portable printing types */


