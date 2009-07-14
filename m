From: Milan Broz <mbroz@redhat.com>
Date: Tue, 14 Jul 2009 13:21:29 +0200
Subject: [PATCH] Enable use new multi-segment registration for static segments too.
Message-ID: <4A5C6A39.7090504@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Enable use new multi-segment registration for static segments.

so it allows adding code like:

#ifdef MYNEWSEG_INTERNAL
	if (!init_mynewseg_segtypes(&seglib))
			return 0;
#endif

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/commands/toolcontext.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 7658c47..76802ab 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -855,10 +855,10 @@ static int _init_single_segtype(struct segtype_library *seglib)
 static int _init_segtypes(struct cmd_context *cmd)
 {
 	struct segment_type *segtype;
+	struct segtype_library seglib = { .cmd = cmd };
 
 #ifdef HAVE_LIBDL
 	const struct config_node *cn;
-	struct segtype_library seglib;
 #endif
 
 	if (!(segtype = init_striped_segtype(cmd)))



