From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:12:15 -0500
Subject: master - base: use calloc
Message-ID: <201811292212.wATMCFWx016246@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8bb5dd54303df384233a06057d9258385d0363ec
Commit:        8bb5dd54303df384233a06057d9258385d0363ec
Parent:        cb04b84c79f10e6b3f1b376cf7611d0afed26c39
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 27 12:12:51 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:05:43 2018 +0100

base: use calloc

Make zalloc a wrapper over calloc
---
 base/memory/zalloc.h |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/base/memory/zalloc.h b/base/memory/zalloc.h
index d2ef827..4f6df54 100644
--- a/base/memory/zalloc.h
+++ b/base/memory/zalloc.h
@@ -20,10 +20,7 @@
 
 static inline void *zalloc(size_t len)
 {
-	void *ptr = malloc(len);
-	if (ptr)
-		memset(ptr, 0, len);
-	return ptr;
+	return calloc(1, len);
 }
 
 //----------------------------------------------------------------


