From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Sep 2014 23:14:52 +0000 (UTC)
Subject: master - debug: mmap traps mmap and mmap64 on i386
Message-ID: <20140918231452.02FA1611A3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2263a3bcf559ef1eba68a6ef6216aca4deaf4d3e
Commit:        2263a3bcf559ef1eba68a6ef6216aca4deaf4d3e
Parent:        9ffc8615e54c804180137b02106c5bff2671061c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 00:59:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 01:10:58 2014 +0200

debug: mmap traps mmap and mmap64 on i386

Add code to trap both mmap implementation on 32bit arch.
Use dlsym()
Use hlt instraction instead of int3 - generates usable stack trace
when problem is catched.
---
 lib/mm/memlock.c |   62 ++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 46 insertions(+), 16 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 25d55f3..a58efd9 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -333,30 +333,35 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 #endif /* DEBUG_MEMLOCK */
 
 #ifdef ARCH_X86
+#ifndef _GNU_SOURCE
+#define _GNU_SOURCE
+#endif
+#include <dlfcn.h>
 static char _mmap_orig;
 static unsigned char *_mmap_addr;
-#endif
+#ifdef __i386__
+static char _mmap64_orig;
+static unsigned char *_mmap64_addr;
+#endif /* __i386__ */
+#endif /* ARCH_X86 */
 
 static int _disable_mmap(void)
 {
 #ifdef ARCH_X86
-	volatile unsigned char *plt, *abs_addr;
+	volatile unsigned char *abs_addr;
 
 	if (!_mmap_addr) {
-		(void) mmap(NULL, -1, -1, -1, -1, -1);
-		plt = (unsigned char *)mmap;
-		if (plt[0] != 0xff || plt[1] != 0x25) {
-			log_debug("Can't find PLT jump entry assuming -fPIE linkage.");
-			_mmap_addr = plt;
-		} else {
+		_mmap_addr = (unsigned char *) dlsym(RTLD_NEXT, "mmap");
+		if (_mmap_addr[0] == 0xff && _mmap_addr[1] == 0x25) { /* plt */
 #ifdef __x86_64__
-			abs_addr = plt + 6 + *(int32_t *)(plt + 2);
+			abs_addr = _mmap_addr + 6 + *(int32_t *)(_mmap_addr + 2);
 #endif /* __x86_64__ */
 #ifdef __i386__
-			abs_addr = *(void **)(plt + 2);
+			abs_addr = *(void **)(_mmap_addr + 2);
 #endif /* __i386__ */
 			_mmap_addr = *(void **)abs_addr;
-		}
+		} else
+			log_debug("Can't find PLT jump entry assuming -fPIE linkage.");
 		if (mprotect((void *)((unsigned long)_mmap_addr & ~4095UL), 4096, PROT_READ|PROT_WRITE|PROT_EXEC)) {
 			log_sys_error("mprotect", "");
 			_mmap_addr = NULL;
@@ -364,8 +369,27 @@ static int _disable_mmap(void)
 		}
 		_mmap_orig = *_mmap_addr;
 	}
-	*_mmap_addr = 0xcc;
+	*_mmap_addr = 0xf4;
 	log_debug("Remapped mmap jump entry %x to %x.", _mmap_orig, *_mmap_addr);
+
+#ifdef __i386__
+	if (!_mmap64_addr) {
+		_mmap64_addr = (unsigned char *) dlsym(RTLD_NEXT, "mmap64");
+		if (_mmap64_addr[0] == 0xff && _mmap64_addr[1] == 0x25) {
+			abs_addr = *(void **)(_mmap64_addr + 2);
+			_mmap64_addr = *(void **)abs_addr;
+		} else
+			log_debug("Can't find PLT jump entry assuming -fPIE linkage.");
+		if (mprotect((void *)((unsigned long)_mmap64_addr & ~4095UL), 4096, PROT_READ|PROT_WRITE|PROT_EXEC)) {
+			log_sys_error("mprotect", "");
+			_mmap64_addr = NULL;
+			return 0;
+		}
+		_mmap64_orig = *_mmap64_addr;
+	}
+	*_mmap64_addr = 0xf4;
+	log_debug("Remapped mmap64 jump entry %x to %x.", _mmap64_orig, *_mmap64_addr);
+#endif /* __i386__ */
 #endif /* ARCH_X86 */
 	return 1;
 }
@@ -373,10 +397,16 @@ static int _disable_mmap(void)
 static int _restore_mmap(void)
 {
 #ifdef ARCH_X86
-	if (!_mmap_addr)
-		return 0;
-	log_debug("Restoring mmap jump entry.");
-	*_mmap_addr = _mmap_orig;
+	if (_mmap_addr) {
+		log_debug("Restoring mmap jump entry.");
+		*_mmap_addr = _mmap_orig;
+	}
+#ifdef __i386__
+	if (_mmap64_addr) {
+		log_debug("Restoring mmap64 jump entry.");
+		*_mmap64_addr = _mmap64_orig;
+	}
+#endif /* __i386__ */
 #endif /* ARCH_X86 */
 	return 1;
 }


