From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 10:35:12 +0000 (UTC)
Subject: master - libdm: do not in include internal bits/time.h header
Message-ID: <20150814103512.B8B7360D3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4534f0fbcf6b83d29baf4af78f9027ff76fe0a7a
Commit:        4534f0fbcf6b83d29baf4af78f9027ff76fe0a7a
Parent:        6a93206882cb628a88dbd372d36dc8fc8cc5053a
Author:        Natanael Copa <ncopa@alpinelinux.org>
AuthorDate:    Fri Aug 14 11:32:36 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 11:33:12 2015 +0100

libdm: do not in include internal bits/time.h header

Do not include bits/time.h as it is an internal libc header file.

A comment at the top of the glibc specific bits/time.h says:
"Never include this file directly; use <time.h> instead."

This fixes the following build error with musl libc:
libdm-timestamp.c:37:23: fatal error: bits/time.h: No such file or directory
---
Compile tested with Alpine Linx (musl libc) and ubuntu 15.04

 libdm/libdm-timestamp.c | 1 -
 1 file changed, 1 deletion(-)
---
 libdm/libdm-timestamp.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

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


