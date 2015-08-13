From: Natanael Copa <ncopa@alpinelinux.org>
Date: Thu, 13 Aug 2015 09:16:28 +0200
Subject: [PATCH] libdm: do not in include internal bits/time.h header
Message-ID: <1439450188-3686-1-git-send-email-ncopa@alpinelinux.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not include bits/time.h as it is an internal libc header file.

A comment at the top of the glibc specific bits/time.h says:
"Never include this file directly; use <time.h> instead."

This fixes the following build error with musl libc:
libdm-timestamp.c:37:23: fatal error: bits/time.h: No such file or directory
---
Compile tested with Alpine Linx (musl libc) and ubuntu 15.04

 libdm/libdm-timestamp.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/libdm/libdm-timestamp.c b/libdm/libdm-timestamp.c
index 3e01442..9be93a4 100644
--- a/libdm/libdm-timestamp.c
+++ b/libdm/libdm-timestamp.c
@@ -34,7 +34,6 @@
 #ifdef HAVE_REALTIME
 
 #include <time.h>
-#include <bits/time.h>
 
 struct dm_timestamp {
 	struct timespec t;
-- 
2.5.0


