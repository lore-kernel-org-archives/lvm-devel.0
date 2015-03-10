From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Mar 2015 13:09:33 +0000 (UTC)
Subject: master - display: fix return values
Message-ID: <20150310130933.DF78961094@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47b704462eea3c93ab5f46d970e5a74a4a5d4e70
Commit:        47b704462eea3c93ab5f46d970e5a74a4a5d4e70
Parent:        1d3711c0b2a1679b18e0ee3032c5d38149a6619b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 9 14:16:41 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 10 14:10:18 2015 +0100

display: fix return values

Return 1 on success in pvdisplay_short() and lvdisplay_full()
so commands like vgdisplay are not printinig stracktraces
on successful passes.

As the results of fail/success have been internally ignored for those
calls, it had no other visible side effect - command's return value was
still 0 (success).
---
 lib/display/display.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index cf3c7f6..2cc5d27 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -385,7 +385,7 @@ int pvdisplay_short(const struct cmd_context *cmd __attribute__((unused)),
 	char uuid[64] __attribute__((aligned(8)));
 
 	if (!pv)
-		return 0;
+		return_0;
 
 	if (!id_write_format(&pv->id, uuid, sizeof(uuid)))
 		return_0;
@@ -399,7 +399,8 @@ int pvdisplay_short(const struct cmd_context *cmd __attribute__((unused)),
 		  pv->pe_count, pv->pe_count - pv->pe_alloc_count);
 
 	log_print(" ");
-	return 0;
+
+	return 1; /* ECMD_PROCESSED */
 }
 
 void lvdisplay_colons(const struct logical_volume *lv)
@@ -623,7 +624,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 
 	log_print(" ");
 
-	return 0;
+	return 1; /* ECMD_PROCESSED */
 }
 
 void display_stripe(const struct lv_segment *seg, uint32_t s, const char *pre)


