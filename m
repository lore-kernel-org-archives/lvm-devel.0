From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Jan 2020 10:47:39 -0500
Subject: master - add suggestion message for mirror LVs
Message-ID: <83902.120011510473502325@us-mta-62.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d53bfae273677975bd805bfaa3d7e7cd995aaa52
Commit:        d53bfae273677975bd805bfaa3d7e7cd995aaa52
Parent:        2f6d0a6408220a1f6a96a9f39779846578d88b8c
Author:        Heming Zhao <heming.zhao@suse.com>
AuthorDate:    Wed Jan 15 02:44:30 2020 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 15 09:46:54 2020 -0600

add suggestion message for mirror LVs

Currently the error messages are not clear. This very easy to
guide user to execute "--removemissing --force", it is dangerous
and will make the LVs to be destroied.

Signed-off-by: Zhao Heming <heming.zhao@suse.com>
---
 tools/vgreduce.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index b001ccb..4a4202e 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -67,6 +67,8 @@ static int _consolidate_vg(struct cmd_context *cmd, struct volume_group *vg)
 		cmd->handles_missing_pvs = 1;
 		log_error("There are still partial LVs in VG %s.", vg->name);
 		log_error("To remove them unconditionally use: vgreduce --removemissing --force.");
+		log_error("To remove them unconditionally from mirror LVs use: vgreduce"
+				  " --removemissing --mirrorsonly --force.");
 		log_warn("WARNING: Proceeding to remove empty missing PVs.");
 	}
 



