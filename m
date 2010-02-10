From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:57:04 +0100
Subject: [PATCH 18/19] Replicator: new variable in generated file
In-Reply-To: <cover.1265813098.git.zkabelac@redhat.com>
References: <cover.1265813098.git.zkabelac@redhat.com>
Message-ID: <9dd2e0f3c9ac2488263e4ef3689656af50227482.1265813098.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/misc/configure.h.in |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 4273eeb..a3ae9ad 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -273,7 +273,7 @@
 /* Define to 1 if you have the `strtoul' function. */
 #undef HAVE_STRTOUL
 
-/* Define to 1 if `st_rdev' is member of `struct stat'. */
+/* Define to 1 if `st_rdev' is a member of `struct stat'. */
 #undef HAVE_STRUCT_STAT_ST_RDEV
 
 /* Define to 1 if you have the <syslog.h> header file. */
@@ -410,6 +410,9 @@
 /* Define to the one symbol short name of this package. */
 #undef PACKAGE_TARNAME
 
+/* Define to the home page for this package. */
+#undef PACKAGE_URL
+
 /* Define to the version of this package. */
 #undef PACKAGE_VERSION
 
@@ -419,6 +422,9 @@
 /* Define to 1 to include the LVM readline shell. */
 #undef READLINE_SUPPORT
 
+/* Define to 1 to include built-in support for replicator. */
+#undef REPLICATOR_INTERNAL
+
 /* Define as the return type of signal handlers (`int' or `void'). */
 #undef RETSIGTYPE
 
-- 
1.6.6.1


