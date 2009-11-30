From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:22 +0100
Subject: [PATCH 22/23] Replicator: new variable in generated file
In-Reply-To: <1259581043-15308-22-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-6-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-7-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-8-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-9-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-10-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-11-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-12-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-13-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-14-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-15-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-16-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-17-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-18-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-19-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-20-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-21-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-22-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-23-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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
1.6.5.3


