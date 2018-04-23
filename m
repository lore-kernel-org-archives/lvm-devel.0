From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:50:08 -0400
Subject: master - scan: skip extra scan in vg_read
Message-ID: <201804231350.w3NDo8uQ031811@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=37471bb4777f3f407d2cd942995b45c326ea221a
Commit:        37471bb4777f3f407d2cd942995b45c326ea221a
Parent:        e4f478d86d6545f6cced7a8ba3bc0b79dccb7b6e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 14 13:49:56 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

scan: skip extra scan in vg_read

Drop an extra label scan in the recovery part
of vg_read.  This is a temporary improvement
until the pending replacement for the broken
recovery code burried in vg_read.
---
 lib/metadata/metadata.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5d3f835..b588a04 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4080,8 +4080,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		/* Independent MDAs aren't supported under low memory */
 		if (!cmd->independent_metadata_areas && prioritized_section())
 			return_NULL;
-		lvmcache_force_next_label_scan();
-		lvmcache_label_scan(cmd);
 		if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0)))
 			return_NULL;
 


