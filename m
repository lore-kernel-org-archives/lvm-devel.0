From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 13 Sep 2010 16:36:10 +0200
Subject: [PATCH] Revert to old glibc behaviour for vsnprintf used in emit_to_buffer function
Message-ID: <4C8E36DA.2050707@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Revert to old glibc behaviour for vsnprintf used in emit_to_buffer fn.
Otherwise, the check that follows would be wrong for new glibc versions.

(This caused the bug #633033 to be undetected and pass throught the check,
corrupting the metadata!)

Peter
---
 lib/misc/lvm-string.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 7eed799..82a3e94 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -27,6 +27,14 @@ int emit_to_buffer(char **buffer, size_t *size, const char *fmt, ...)
 	n = vsnprintf(*buffer, *size, fmt, ap);
 	va_end(ap);
 
+	/*
+	 * Revert to old glibc behaviour (version <= 2.0.6) where snprintf
+	 * returned -1 if buffer was too small. From glibc 2.1 it returns number
+	 * of chars that would have been written had there been room.
+	 */
+	if (n < 0 || ((unsigned) n + 1 > *size))
+		n = -1;
+
 	if (n < 0 || ((size_t)n == *size))
 		return 0;
 


