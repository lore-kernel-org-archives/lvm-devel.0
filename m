From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:25 -0500
Subject: master - toolcontext: light context missed to set-up mem mempool
Message-ID: <201802122120.w1CLKPGu023642@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=afdbb28f7222b3a5a38964d47d750aad8aec12f6
Commit:        afdbb28f7222b3a5a38964d47d750aad8aec12f6
Parent:        34a9e3d3cdde5771e30fbd686b20ffba1647a497
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 9 15:39:14 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:13:53 2018 +0100

toolcontext: light context missed to set-up mem mempool

If cmd->mem was null, then systemd generator was failing on:

(gdb) bt
dm_pool_alloc_aligned (p=0x0, s=96, alignment=8) at mm/pool-fast.c:95
dm_pool_alloc (p=0x0, s=96) at mm/pool-fast.c:90
dm_pool_zalloc (p=0x0, s=96) at mm/pool.c:74
config_file_read_fd (mem=0x0, cft=0x55f4339dbad0, dev=0x55f4339dfac0, reason=DEV_IO_MDA_CONTENT, offset=0, size=82293, offset2=0, size2=0,
    checksum_fn=0x0, checksum=0, checksum_only=0, no_dup_node_check=0, ioflags=0, config_file_read_fd_callback=0x0, config_file_read_fd_context=0x0) at config/config.c:567
config_file_read (mem=0x0, cft=0x55f4339dbad0) at config/config.c:658
config_file_open_and_read (config_file=0x7f49aef14540 <config_file> "/var/tmp/lvm/etc/lvm/lvm.conf", source=CONFIG_FILE, cmd=0x55f4339d6260)
    at config/config.c:282
_load_config_file (cmd=0x55f4339d6260, tag=0x7f49aeca15da "", local=0) at commands/toolcontext.c:824
_init_lvm_conf (cmd=0x55f4339d6260) at commands/toolcontext.c:853
create_config_context () at commands/toolcontext.c:1814
lvm_config_find_bool (libh=0x0, config_path=0x55f431a884ad "global/use_lvmetad", fail=0) at lvm_base.c:144
main ()
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bf46281..74f9616 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Add missing initialisation of mem pool in systemd generator.
   Do not reopen output streams for multithreaded users of liblvm.
   Use versionsort to fix archive file expiry beyond 100000 files.
   Add devices/use_aio, aio_max, aio_memory to configure AIO limits.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index ba757dd..b613b8f 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1792,6 +1792,8 @@ void destroy_config_context(struct cmd_context *cmd)
 /*
  * A "config context" is a very light weight toolcontext that
  * is only used for reading config settings from lvm.conf.
+ *
+ * FIXME: this needs to go back to parametrized create_toolcontext()
  */
 struct cmd_context *create_config_context(void)
 {
@@ -1808,6 +1810,9 @@ struct cmd_context *create_config_context(void)
 	if (!(cmd->libmem = dm_pool_create("library", 4 * 1024)))
 		goto_out;
 
+	if (!(cmd->mem = dm_pool_create("command", 4 * 1024)))
+		goto out;
+
 	dm_list_init(&cmd->config_files);
 	dm_list_init(&cmd->tags);
 


