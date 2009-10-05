From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  5 Oct 2009 16:00:31 +0200
Subject: [PATCH 04/13] Replicator: new variable in generated file
In-Reply-To: <1254751240-17431-3-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-3-git-send-email-zkabelac@redhat.com>
Message-ID: <1254751240-17431-4-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/misc/configure.h.in |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 4273eeb..a49cd6e 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -419,6 +419,9 @@
 /* Define to 1 to include the LVM readline shell. */
 #undef READLINE_SUPPORT
 
+/* Define to 1 to include built-in support for replicator. */
+#undef REPLICATOR_INTERNAL
+
 /* Define as the return type of signal handlers (`int' or `void'). */
 #undef RETSIGTYPE
 
-- 
1.6.5.rc2


