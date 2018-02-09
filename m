From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Feb 2018 05:01:45 -0500
Subject: master - partial revert "command: Skip some memory zeroing."
Message-ID: <201802091001.w19A1j0x011123@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7cfe5ab9bc279bb1cea42862a53d83556fb3ed52
Commit:        7cfe5ab9bc279bb1cea42862a53d83556fb3ed52
Parent:        83258e33852166a3111a009f1720cc87f62efc73
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 9 10:51:02 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 9 10:59:07 2018 +0100

partial revert "command: Skip some memory zeroing."

This partially reverts commit da37cbd24fc0073f3f00a3b7aac7807d2185b829.
As the _cmdline structure use mempool for allocated ellement
that is being release on cmd_context close.

Before the better fix is made - restore previous logic and
reinitialize cmd structures again for new cmd_context.

Problem can be hit with e.g. this test run:

make check_local T=foreign LVM_VALGRIND_DMEVENTD=1

Invalid read of size 1
   at 0x4C31C83: strcmp (vg_replace_strmem.c:846)
   by 0x6BA0939: _find_command (lvmcmdline.c:1555)
   by 0x6BA4304: lvm_run_command (lvmcmdline.c:2810)
   by 0x6BD5E02: lvm2_run (lvmcmdlib.c:91)
   by 0x685607E: dmeventd_lvm2_run (dmeventd_lvm.c:118)
   by 0x6652684: _use_policy (dmeventd_thin.c:117)
   by 0x6652E56: process_event (dmeventd_thin.c:298)
   by 0x10CC5A: _do_process_event (dmeventd.c:945)
   by 0x10CF83: _monitor_thread (dmeventd.c:1033)
   by 0x54B35E0: start_thread (in /usr/lib64/libpthread-2.26.9000.so)
   by 0x57C30EE: clone (in /usr/lib64/libc-2.26.9000.so)
 Address 0x6266270 is 4,352 bytes inside a block of size 8,192 free'd
   at 0x4C2ED68: free (vg_replace_malloc.c:530)
   by 0x5289142: dm_free_wrapper (dbg_malloc.c:393)
   by 0x528998A: _free_chunk (pool-fast.c:318)
   by 0x52892A6: dm_pool_destroy (pool-fast.c:78)
   by 0x6A8E52C: destroy_toolcontext (toolcontext.c:2254)
   by 0x6BA5BD6: lvm_fin (lvmcmdline.c:3327)
   by 0x6BD5EA7: lvm2_exit (lvmcmdlib.c:123)
   by 0x6856013: dmeventd_lvm2_exit (dmeventd_lvm.c:103)
   by 0x66535B8: unregister_device (dmeventd_thin.c:432)
   by 0x10CBBC: _do_unregister_device (dmeventd.c:926)
   by 0x10CD74: _monitor_unregister (dmeventd.c:979)
   by 0x10D094: _monitor_thread (dmeventd.c:1066)
   by 0x54B35E0: start_thread (in /usr/lib64/libpthread-2.26.9000.so)
   by 0x57C30EE: clone (in /usr/lib64/libc-2.26.9000.so)
 Block was alloc'd at
   at 0x4C2DBBB: malloc (vg_replace_malloc.c:299)
   by 0x5288F46: dm_malloc_aux (dbg_malloc.c:287)
   by 0x52890AC: dm_malloc_wrapper (dbg_malloc.c:371)
   by 0x52898E6: _new_chunk (pool-fast.c:286)
   by 0x52893BA: dm_pool_alloc_aligned (pool-fast.c:106)
   by 0x5289310: dm_pool_alloc (pool-fast.c:90)
   by 0x6A8A21A: _load_config_file (toolcontext.c:808)
   by 0x6A8A3D9: _init_lvm_conf (toolcontext.c:842)
   by 0x6A8D3BD: create_toolcontext (toolcontext.c:1941)
   by 0x6BA5B24: init_lvm (lvmcmdline.c:3308)
   by 0x6BD5B7C: cmdlib_lvm2_init (lvmcmdlib.c:34)
   by 0x6BD5EB8: lvm2_init (lvm2cmd.c:20)
   by 0x6855EA7: dmeventd_lvm2_init (dmeventd_lvm.c:67)
   by 0x665305F: register_device (dmeventd_thin.c:352)
   by 0x10CB7A: _do_register_device (dmeventd.c:916)
   by 0x10CEE4: _monitor_thread (dmeventd.c:1006)
   by 0x54B35E0: start_thread (in /usr/lib64/libpthread-2.26.9000.so)
   by 0x57C30EE: clone (in /usr/lib64/libc-2.26.9000.so)
---
 tools/lvmcmdline.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 246d332..6be4bcd 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1262,6 +1262,15 @@ static const struct command_function *_find_command_id_function(int command_enum
 	return NULL;
 }
 
+static void _unregister_commands(void)
+{
+	_cmdline.commands = NULL;
+	_cmdline.num_commands = 0;
+	_cmdline.command_names = NULL;
+	_cmdline.num_command_names = 0;
+	memset(&commands, 0, sizeof(commands));
+}
+
 int lvm_register_commands(struct cmd_context *cmd, const char *run_name)
 {
 	int i;
@@ -1270,6 +1279,8 @@ int lvm_register_commands(struct cmd_context *cmd, const char *run_name)
 	if (_cmdline.commands)
 		return 1;
 
+	memset(&commands, 0, sizeof(commands));
+
 	/*
 	 * populate commands[] array with command definitions
 	 * by parsing command-lines.in/command-lines-input.h
@@ -3324,6 +3335,7 @@ struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters)
 
 void lvm_fin(struct cmd_context *cmd)
 {
+	_unregister_commands();
 	destroy_toolcontext(cmd);
 	udev_fin_library_context();
 }


