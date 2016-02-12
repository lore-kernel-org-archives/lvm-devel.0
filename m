From: okozina <okozina@fedoraproject.org>
Date: Fri, 12 Feb 2016 10:41:46 +0000 (UTC)
Subject: master - pvmove: fix possible memory pool corruption
Message-ID: <20160212104146.C845F60BBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0daf9d7ac5009d7c5642a6b1c7d8bb3fbc0c4382
Commit:        0daf9d7ac5009d7c5642a6b1c7d8bb3fbc0c4382
Parent:        a077a649837b6d60d892516e32be8854bfb57ee7
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Feb 12 11:34:26 2016 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri Feb 12 11:40:33 2016 +0100

pvmove: fix possible memory pool corruption

This is a hotfix for a bug introduced in
6d7dc87cb356162f912b13c8a0cd198037c0226b.

The bug description: First we allocate memory for
processing handle (at an address 1) then we
allocate some memory on the same pool for later use
in pvmove_poll function inside the process_each_pv
function (at an address 2). After we jump out of
process_each_pv we called destroy_processing_handle.
As a result of destroying the handle memory pool could
deallocate all memory at address 1 or higher. The
pvmove_poll function tried to copy a memory allocated
at address 2 that could be returned to the system.
If it was so it led to segfault.

We need to rethink proper fix but in the same time
cmd->mem pool is recreated per each lvm command so
this should not cause problems even when we run
multiple commands in lvm shell.

A valgrind snapshot of the corruption:

Invalid read of size 1
    at 0x4C29F92: strlen (mc_replace_strmem.c:403)
    by 0x5495F2E: dm_pool_strdup (pool.c:51)
    by 0x1592A7: _create_id (pvmove.c:774)
    by 0x159409: pvmove_poll (pvmove.c:796)
    by 0x1599E3: pvmove (pvmove.c:931)
    by 0x15105B: lvm_run_command (lvmcmdline.c:1655)
    by 0x1523C3: lvm2_main (lvmcmdline.c:2121)
    by 0x1754F3: main (lvm.c:22)
Address 0xf15df8a is 138 bytes inside a block of size 8,192 free'd
    at 0x4C28430: free (vg_replace_malloc.c:446)
    by 0x5494E73: dm_free_wrapper (dbg_malloc.c:357)
    by 0x5495DE2: _free_chunk (pool-fast.c:318)
    by 0x549561C: dm_pool_free (pool-fast.c:151)
    by 0x164451: destroy_processing_handle (toollib.c:1837)
    by 0x1598C1: pvmove (pvmove.c:903)
    by 0x15105B: lvm_run_command (lvmcmdline.c:1655)
    by 0x1523C3: lvm2_main (lvmcmdline.c:2121)
    by 0x1754F3: main (lvm.c:22)
---
 WHATS_NEW       |    1 +
 tools/toollib.c |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7b10da8..8c3a204 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.142 - 
 ====================================
+  Fix memory pool corruption in pvmove (2.02.141).
   Support control of spare metadata creation when repairing thin-pool.
   Fix config type of 'log/verbose' from bool to int (2.02.99).
   Fix thinp watermark calc for data LV for faster dmeventd responce (2.02.133).
diff --git a/tools/toollib.c b/tools/toollib.c
index c89d8e5..f9ac259 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1834,7 +1834,11 @@ void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle
 	if (handle) {
 		if (handle->selection_handle && handle->selection_handle->selection_rh)
 			dm_report_free(handle->selection_handle->selection_rh);
-		dm_pool_free(cmd->mem, handle);
+		/*
+		 * TODO: think about better alternatives:
+		 * handle mempool, dm_alloc for handle memory...
+		 */
+		memset(handle, 0, sizeof(*handle));
 	}
 }
 


