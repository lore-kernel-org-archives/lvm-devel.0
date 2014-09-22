From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:04 +0000 (UTC)
Subject: dev-dct-process-latest - debug: catch mmap with -DDEBUG_MEMLOCK
Message-ID: <20140922153904.E699760C1A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d21438d0c64267ac11b4825ad719c458b80059e
Commit:        6d21438d0c64267ac11b4825ad719c458b80059e
Parent:        31548e4e7c4e3ae3b2f04b7b32491617ec7181d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 18 00:40:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 18 00:48:06 2014 +0200

debug: catch mmap with -DDEBUG_MEMLOCK

---
 lib/mm/memlock.c |   68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 make.tmpl.in     |    4 +++
 2 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 7d9a8f3..72575c5 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -316,6 +316,71 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 	return ret;
 }
 
+#ifdef DEBUG_MEMLOCK
+/*
+ * LVM is not supposed to use mmap while devices are suspended.
+ * This code causes a core dump if gets called."
+ */
+#  ifdef __i386__
+#    define ARCH_X86
+#  endif /* __i386__ */
+#  ifdef __x86_64__
+#    ifndef ARCH_X86
+#      define ARCH_X86
+#    endif /* ARCH_X86 */
+#  endif /* __x86_64__ */
+
+#endif /* DEBUG_MEMLOCK */
+
+#ifdef ARCH_X86
+static char _mmap_orig;
+static unsigned char *_mmap_addr;
+#endif
+
+static int _disable_mmap(void)
+{
+#ifdef ARCH_X86
+	volatile unsigned char *plt, *abs_addr;
+
+	if (!_mmap_addr) {
+		(void) mmap(NULL, -1, -1, -1, -1, -1);
+		plt = (unsigned char *)mmap;
+		if (plt[0] != 0xff || plt[1] != 0x25) {
+			log_error("Can't find jump entry for mmap remapping.");
+			_mmap_addr = NULL;
+			return 0;
+		}
+#ifdef __x86_64__
+		abs_addr = plt + 6 + *(int32_t *)(plt + 2);
+#endif /* __x86_64__ */
+#ifdef __i386__
+		abs_addr = *(void **)(plt + 2);
+#endif /* __i386__ */
+		_mmap_addr = *(void **)abs_addr;
+		if (mprotect((void *)((unsigned long)_mmap_addr & ~4095UL), 4096, PROT_READ|PROT_WRITE|PROT_EXEC)) {
+			log_sys_error("mprotect", "");
+			_mmap_addr = NULL;
+			return 1;
+		}
+		_mmap_orig = *_mmap_addr;
+	}
+	*_mmap_addr = 0xcc;
+	log_debug("Remapped mmap jump entry %x to %x.", _mmap_orig, *_mmap_addr);
+#endif /* ARCH_X86 */
+	return 1;
+}
+
+static int _restore_mmap(void)
+{
+#ifdef ARCH_X86
+	if (!_mmap_addr)
+		return 0;
+	log_debug("Restoring mmap jump entry.");
+	*_mmap_addr = _mmap_orig;
+#endif /* ARCH_X86 */
+	return 1;
+}
+
 /* Stop memory getting swapped out */
 static void _lock_mem(struct cmd_context *cmd)
 {
@@ -345,6 +410,8 @@ static void _lock_mem(struct cmd_context *cmd)
 	}
 
 	log_very_verbose("Locking memory");
+	if (!_disable_mmap())
+		stack;
 	if (!_memlock_maps(cmd, LVM_MLOCK, &_mstats))
 		stack;
 
@@ -366,6 +433,7 @@ static void _unlock_mem(struct cmd_context *cmd)
 	if (!_memlock_maps(cmd, LVM_MUNLOCK, &unlock_mstats))
 		stack;
 
+	_restore_mmap();
 	if (!_use_mlockall) {
 		if (close(_maps_fd))
 			log_sys_error("close", _procselfmaps);
diff --git a/make.tmpl.in b/make.tmpl.in
index 455e9c2..7a178ad 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -214,6 +214,10 @@ endif
 #DEFS += -DDEBUG_ENFORCE_POOL_LOCKING
 #DEFS += -DBOUNDS_CHECK
 
+# LVM is not supposed to use mmap while devices are suspended.
+# This code causes a core dump if gets called.
+#DEFS += -DDEBUG_MEMLOCK
+
 #CFLAGS += -pg
 #LDFLAGS += -pg
 


