From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Sep 2014 13:57:49 +0000 (UTC)
Subject: master - debug: enhance mmap catch code
Message-ID: <20140919135749.2FB0A6030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=386fbf8e0d30823854ffefb1b4e3b47b09ec5905
Commit:        386fbf8e0d30823854ffefb1b4e3b47b09ec5905
Parent:        081e406d0d0c02d8fb6f93d6b8fb97f4217fde62
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 11:04:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 15:55:47 2014 +0200

debug: enhance mmap catch code

Use nice instruction_HLT macro
Use log_debug_mem()
Don't actually log things after we prohibit 'mmap'.
Move initialization of strerror & udev before blocking mmap.
---
 lib/mm/memlock.c |   29 ++++++++++++-----------------
 1 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 0658800..37d9457 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -334,6 +334,7 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 #define _GNU_SOURCE
 #endif
 #include <dlfcn.h>
+static const unsigned char INSTRUCTION_HLT = 0x94;
 static char _mmap_orig;
 static unsigned char *_mmap_addr;
 #ifdef __i386__
@@ -358,7 +359,7 @@ static int _disable_mmap(void)
 #endif /* __i386__ */
 			_mmap_addr = *(void **)abs_addr;
 		} else
-			log_debug("Can't find PLT jump entry assuming -fPIE linkage.");
+			log_debug_mem("Can't find PLT jump entry assuming -fPIE linkage.");
 		if (mprotect((void *)((unsigned long)_mmap_addr & ~4095UL), 4096, PROT_READ|PROT_WRITE|PROT_EXEC)) {
 			log_sys_error("mprotect", "");
 			_mmap_addr = NULL;
@@ -366,8 +367,8 @@ static int _disable_mmap(void)
 		}
 		_mmap_orig = *_mmap_addr;
 	}
-	*_mmap_addr = 0xf4;
-	log_debug("Remapped mmap jump entry %x to %x.", _mmap_orig, *_mmap_addr);
+	log_debug_mem("Remapping mmap entry %02x to %02x.", _mmap_orig, INSTRUCTION_HLT);
+	*_mmap_addr = INSTRUCTION_HLT;
 
 #ifdef __i386__
 	if (!_mmap64_addr) {
@@ -375,8 +376,7 @@ static int _disable_mmap(void)
 		if (_mmap64_addr[0] == 0xff && _mmap64_addr[1] == 0x25) {
 			abs_addr = *(void **)(_mmap64_addr + 2);
 			_mmap64_addr = *(void **)abs_addr;
-		} else
-			log_debug("Can't find PLT jump entry assuming -fPIE linkage.");
+		} /* Can't find PLT jump entry assuming -fPIE linkage */
 		if (mprotect((void *)((unsigned long)_mmap64_addr & ~4095UL), 4096, PROT_READ|PROT_WRITE|PROT_EXEC)) {
 			log_sys_error("mprotect", "");
 			_mmap64_addr = NULL;
@@ -384,8 +384,7 @@ static int _disable_mmap(void)
 		}
 		_mmap64_orig = *_mmap64_addr;
 	}
-	*_mmap64_addr = 0xf4;
-	log_debug("Remapped mmap64 jump entry %x to %x.", _mmap64_orig, *_mmap64_addr);
+	*_mmap64_addr = INSTRUCTION_HLT;
 #endif /* __i386__ */
 #endif /* ARCH_X86 */
 	return 1;
@@ -394,16 +393,13 @@ static int _disable_mmap(void)
 static int _restore_mmap(void)
 {
 #ifdef ARCH_X86
-	if (_mmap_addr) {
-		log_debug("Restoring mmap jump entry.");
+	if (_mmap_addr)
 		*_mmap_addr = _mmap_orig;
-	}
 #ifdef __i386__
-	if (_mmap64_addr) {
-		log_debug("Restoring mmap64 jump entry.");
+	if (_mmap64_addr)
 		*_mmap64_addr = _mmap64_orig;
-	}
 #endif /* __i386__ */
+	log_debug_mem("Restored mmap entry.");
 #endif /* ARCH_X86 */
 	return 1;
 }
@@ -412,6 +408,9 @@ static int _restore_mmap(void)
 static void _lock_mem(struct cmd_context *cmd)
 {
 	_allocate_memory();
+	(void)strerror(0);		/* Force libc.mo load */
+	(void)dm_udev_get_sync_support(); /* udev is initialized */
+	log_very_verbose("Locking memory");
 
 	/*
 	 * For daemon we need to use mlockall()
@@ -439,10 +438,6 @@ static void _lock_mem(struct cmd_context *cmd)
 			stack;
 	}
 
-	(void)strerror(0);		/* Force libc.mo load */
-	(void)dm_udev_get_sync_support(); /* udev is initialized */
-
-	log_very_verbose("Locking memory");
 	if (!_memlock_maps(cmd, LVM_MLOCK, &_mstats))
 		stack;
 


