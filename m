From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 12 May 2016 18:08:07 +0000 (UTC)
Subject: master - lib: fix init error handling
Message-ID: <20160512180807.0E84A60C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87d9406725b23e6c01e55014606ff047d7375951
Commit:        87d9406725b23e6c01e55014606ff047d7375951
Parent:        a6203657a0bf4b15017724a8212cc61a8672afa5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 12 13:00:33 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 12 13:07:52 2016 -0500

lib: fix init error handling

When setting up a toolcontext, the lib init function
was detecting an error when there was none, and then
it was returning an incompletely initialized cmd struct
instead of NULL.  The effect was that the lib would try
to use the uninitialized cmd struct and segfault.
This would happen if a non-fatal error occurred during
cmd setup, e.g. user permission failed on lvmetad socket,
causing cmd to fall back to scanning and not use lvmetad.

The only real error condition is when create_toolcontext
returns NULL.  If cmd is returned, the lib can use it.
---
 lib/commands/toolcontext.c |    2 +-
 liblvm/lvm_base.c          |    3 ---
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 31f3a50..90e5d5a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1945,7 +1945,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	_init_globals(cmd);
 
 	if (set_connections && !init_connections(cmd))
-		return_0;
+		goto_out;
 
 	if (set_filters && !init_filters(cmd, 1))
 		goto_out;
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index fd37568..8b4def2 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -49,9 +49,6 @@ static lvm_t _lvm_init(const char *system_dir)
 	if (!cmd)
 		return NULL;
 
-	if (stored_errno())
-		return (lvm_t) cmd;
-
 	/*
 	 * FIXME: if an non memory error occured, return the cmd (maybe some
 	 * cleanup needed).


