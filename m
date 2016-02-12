From: okozina <okozina@fedoraproject.org>
Date: Fri, 12 Feb 2016 10:07:36 +0000 (UTC)
Subject: master - pvmove: fix memory pool corruption
Message-ID: <20160212100736.0C5D5606D7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a80cc5bc3799483a211b2ff9677a392a7b47e8b
Commit:        8a80cc5bc3799483a211b2ff9677a392a7b47e8b
Parent:        a077a649837b6d60d892516e32be8854bfb57ee7
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu Feb 11 15:41:29 2016 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri Feb 12 11:07:21 2016 +0100

pvmove: fix memory pool corruption

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

We don't have to call destroy_processing_handle() since
the mempool is freed automatically during command context
teardown.

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
 WHATS_NEW      |    1 +
 tools/pvmove.c |    2 --
 2 files changed, 1 insertions(+), 2 deletions(-)

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
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 0b8ca46..21f2eab 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -900,8 +900,6 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 				handle,
 				is_abort ? &_pvmove_read_single : &_pvmove_setup_single);
 
-		destroy_processing_handle(cmd, handle);
-
 		if (!is_abort) {
 			if (!pp.found_pv) {
 				stack;


