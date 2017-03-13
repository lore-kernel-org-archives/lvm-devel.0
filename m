From: David Teigland <teigland@sourceware.org>
Date: Mon, 13 Mar 2017 15:54:58 -0400
Subject: master - lvmetad: fix segfault on i386
Message-ID: <201703131954.v2DJswLr000699@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46b735c937ce68e72d08997635321bf30240325d
Commit:        46b735c937ce68e72d08997635321bf30240325d
Parent:        5f2c942000b9e59105441eeaea7233b6c9c4f493
Author:        Christian Brauner <christian.brauner@canonical.com>
AuthorDate:    Sat Mar 11 01:08:43 2017 +0100
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 13 13:37:07 2017 -0500

lvmetad: fix segfault on i386

Sending %d as format argument in lvmetad_vg_remove_pending() will cause
segfaults in config_make_nodes_v() when va_arg() casts to int64_t. Also, it is
clearly advertised in the lvm source code that using plain %d is prohibited, so
let's switch to FMTd64.

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 lib/cache/lvmetad.c            |    2 +-
 libdaemon/client/config-util.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 8e9bb1f..843e1c3 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1304,7 +1304,7 @@ int lvmetad_vg_remove_pending(struct volume_group *vg)
 	reply = _lvmetad_send(vg->cmd, "set_vg_info",
 			      "name = %s", vg->name,
 			      "uuid = %s", uuid,
-			      "version = %d", 0,
+			      "version = %"PRId64, (int64_t)0,
 			      NULL);
 
 	if (!_lvmetad_handle_reply(reply, "set_vg_info", vg->name, NULL)) {
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 93f3d0a..5b6cfb8 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -260,7 +260,7 @@ struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
 		key[fmt - next] = '\0';
 		fmt += 2;
 
-		if (!strcmp(fmt, "%d") || !strcmp(fmt, FMTd64)) {
+		if (!strcmp(fmt, FMTd64)) {
 			int64_t value = va_arg(ap, int64_t);
 			if (!(cn = make_int_node(cft, key, value, parent, pre_sib)))
 				return 0;


