From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Sep 2014 14:58:27 +0000 (UTC)
Subject: master - debug: enhance trap of mmap
Message-ID: <20140918145827.356E960DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d450c7fb102652985a7271f3ea76ed72235060e7
Commit:        d450c7fb102652985a7271f3ea76ed72235060e7
Parent:        34bdb83c52ddc3533b16d923953435e576699877
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 18 16:56:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 18 16:56:13 2014 +0200

debug: enhance trap of mmap

Don't install trap for mlockall case
Add another code path for -fPIE compilation,
in this case the address of mmap function is 'plt' address.
---
 lib/mm/memlock.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 72575c5..25d55f3 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -346,21 +346,21 @@ static int _disable_mmap(void)
 		(void) mmap(NULL, -1, -1, -1, -1, -1);
 		plt = (unsigned char *)mmap;
 		if (plt[0] != 0xff || plt[1] != 0x25) {
-			log_error("Can't find jump entry for mmap remapping.");
-			_mmap_addr = NULL;
-			return 0;
-		}
+			log_debug("Can't find PLT jump entry assuming -fPIE linkage.");
+			_mmap_addr = plt;
+		} else {
 #ifdef __x86_64__
-		abs_addr = plt + 6 + *(int32_t *)(plt + 2);
+			abs_addr = plt + 6 + *(int32_t *)(plt + 2);
 #endif /* __x86_64__ */
 #ifdef __i386__
-		abs_addr = *(void **)(plt + 2);
+			abs_addr = *(void **)(plt + 2);
 #endif /* __i386__ */
-		_mmap_addr = *(void **)abs_addr;
+			_mmap_addr = *(void **)abs_addr;
+		}
 		if (mprotect((void *)((unsigned long)_mmap_addr & ~4095UL), 4096, PROT_READ|PROT_WRITE|PROT_EXEC)) {
 			log_sys_error("mprotect", "");
 			_mmap_addr = NULL;
-			return 1;
+			return 0;
 		}
 		_mmap_orig = *_mmap_addr;
 	}
@@ -407,11 +407,12 @@ static void _lock_mem(struct cmd_context *cmd)
 			log_sys_error("open", _procselfmaps);
 			return;
 		}
+
+		if (!_disable_mmap())
+			stack;
 	}
 
 	log_very_verbose("Locking memory");
-	if (!_disable_mmap())
-		stack;
 	if (!_memlock_maps(cmd, LVM_MLOCK, &_mstats))
 		stack;
 
@@ -433,8 +434,8 @@ static void _unlock_mem(struct cmd_context *cmd)
 	if (!_memlock_maps(cmd, LVM_MUNLOCK, &unlock_mstats))
 		stack;
 
-	_restore_mmap();
 	if (!_use_mlockall) {
+		_restore_mmap();
 		if (close(_maps_fd))
 			log_sys_error("close", _procselfmaps);
 		dm_free(_maps_buffer);


