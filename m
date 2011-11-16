From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:56 +0100
Subject: [PATCH 09/12] Limit max stack size
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <418aee1d85467810cc425db607d076985984a92e.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For now CLMVD allocates 128KiB for each thread which is
twice the DEFAULT_RESERVED_STACK that happens to be 64KiB so
we cannot support to prealllocate the arbitrary large stack size.

With this whole patchset applied it could be seen, the whole test-suite
is passing even with just 32KiB preallocated stack with still some KiB
left. So there is probably no point to allow allocation of more then
64KiB.

We can have number of solutions here - ideally I'd drop the whole
configurability of stack prealloction and leave it for internal code
to know better what the stack size is needed.

Without this patch every CLVMD user which have activation/reserved_stack
set to 256KiB (which was default prior 2.02.89) will get clvmd crash
after start.

IMHO the worst option is to implement lvm.conf parsing into
clvmd, to find out reserved_size and update pthread stack size to
accomodate this value (since currently clvmd does not use lvm.conf -
only its lvm threads).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mm/memlock.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 8bf9f22..b9fc430 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -446,8 +446,13 @@ void memlock_dec_daemon(struct cmd_context *cmd)
 void memlock_init(struct cmd_context *cmd)
 {
 	_size_stack = find_config_tree_int(cmd,
-				      "activation/reserved_stack",
-				      DEFAULT_RESERVED_STACK) * 1024;
+					   "activation/reserved_stack",
+					   DEFAULT_RESERVED_STACK) * 1024;
+	if (_size_stack > (DEFAULT_RESERVED_STACK * 1024)) {
+		_size_stack = DEFAULT_RESERVED_STACK * 1024;
+		log_verbose("Using maximum supported prealloc stack size %uKB",
+			    DEFAULT_RESERVED_STACK);
+	}
 	_size_malloc_tmp = find_config_tree_int(cmd,
 					   "activation/reserved_memory",
 					   DEFAULT_RESERVED_MEMORY) * 1024;
-- 
1.7.7.3


