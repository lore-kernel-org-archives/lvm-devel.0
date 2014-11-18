From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 18 Nov 2014 15:28:07 +0000 (UTC)
Subject: master - toollib: improve ignore_vg case in _process_pvs_in_vgs
Message-ID: <20141118152807.71A616055B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aaa6205d5ad4beb8a54d56f9285cafb5dbd5c7b4
Commit:        aaa6205d5ad4beb8a54d56f9285cafb5dbd5c7b4
Parent:        cf37c04347c6b6209420764da43127a96445af0e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 18 09:22:37 2014 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 18 09:25:56 2014 -0600

toollib: improve ignore_vg case in _process_pvs_in_vgs

ignore_vg now returns 0 for the FAILED_CLUSTERED case,
so all the ignore_vg 1 cases will return vg's with an
empty vg->pvs, so we do not need to iterate through
vg->pvs to remove the entries from the devices list.

Clean up whitespace problems in that area from the
previous commit.
---
 tools/toollib.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 8eb434d..30dc980 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2200,25 +2200,26 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		vg = vg_read(cmd, vg_name, vg_uuid, flags | READ_WARN_INCONSISTENT);
 		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
-			ret = ECMD_FAILED;
-			skip = 1;
-
-			/* Only continue if no vg was returned. */
-			if (!vg)
-				continue;
+			ret_max = ECMD_FAILED;
+			continue;
 		}
 		
+		/*
+		 * Don't continue when skip is set, because we need to remove
+		 * vg->pvs entries from devices list.
+		 */
+		
 		ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_pvnames, arg_tags,
 					 process_all, skip, handle, process_single_pv);
 		if (ret != ECMD_PROCESSED)
 			stack;
-		 if (ret > ret_max)
+		if (ret > ret_max)
 			ret_max = ret;
 
-		 if (skip)
-			 release_vg(vg);
-		 else
-			 unlock_and_release_vg(cmd, vg, vg->name);
+		if (skip)
+			release_vg(vg);
+		else
+			unlock_and_release_vg(cmd, vg, vg->name);
 
 		/* Quit early when possible. */
 		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_pvnames))


