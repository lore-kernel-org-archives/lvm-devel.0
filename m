From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Mar 2010 13:07:27 +0100
Subject: [PATCH 9/9] misc/configure.in modification
In-Reply-To: <cover.1267529065.git.zkabelac@redhat.com>
References: <cover.1267529065.git.zkabelac@redhat.com>
Message-ID: <68c18baf8724b03712de4de29d115e8e21214ada.1267529065.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is generated file from autoreconf.
We no longer define HAVE_LIBREADLINE - we have not used it
before anyway.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/misc/configure.h.in |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 4273eeb..b0af63f 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -120,9 +120,6 @@
 /* Define to 1 if you have the <libintl.h> header file. */
 #undef HAVE_LIBINTL_H
 
-/* Define to 1 if you have the `readline' library (-lreadline). */
-#undef HAVE_LIBREADLINE
-
 /* Define to 1 if you have the <limits.h> header file. */
 #undef HAVE_LIMITS_H
 
-- 
1.7.0


