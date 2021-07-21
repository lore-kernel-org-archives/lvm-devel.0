From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jul 2021 13:57:18 +0000 (GMT)
Subject: main - vgremove: remove forgotten pmspare
Message-ID: <20210721135718.887083858406@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5042463c5083cc71546297344058bd0fa523aa5c
Commit:        5042463c5083cc71546297344058bd0fa523aa5c
Parent:        d38fdb25e4debc035f1e4585432c2627460d5e50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 20 22:28:13 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 21 13:19:51 2021 +0200

vgremove: remove forgotten pmspare

As pmspare is an invisible LV it's not getting automatically removed
since vgremove removes only visible LVs and it depending LVs.
If there was no other thin/cache pool volume, such pmspare stayed
undeleted and caused command failure.

So handle explicitelly such forgotten pmspare and remove it.
---
 tools/vgremove.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/vgremove.c b/tools/vgremove.c
index 8f73297dc..b6685ae2a 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -65,6 +65,10 @@ static int _vgremove_single(struct cmd_context *cmd, const char *vg_name,
 		}
 	}
 
+	if (vg->pool_metadata_spare_lv &&
+	    !lvremove_single(cmd, vg->pool_metadata_spare_lv, &void_handle))
+		return_ECMD_FAILED;
+
 	if (!lockd_free_vg_before(cmd, vg, 0))
 		return_ECMD_FAILED;
 


