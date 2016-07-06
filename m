From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  6 Jul 2016 19:13:07 +0000 (UTC)
Subject: master - vgcreate: allow pvcreate force option
Message-ID: <20160706191307.283B560E3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d1c4e1f7339746eacc850f45085ecd75bfd56a1
Commit:        4d1c4e1f7339746eacc850f45085ecd75bfd56a1
Parent:        351bcf5f82a76b897cd431e3709759507566ee7b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 6 14:10:53 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 6 14:10:53 2016 -0500

vgcreate: allow pvcreate force option

Commit a9940bd3c92 began disallowing the -f (force) option
to apply to the implicit pvcreate.  Make it allowed again.
---
 tools/vgcreate.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 1a6a240..af0c363 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -49,9 +49,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	/* Don't create a new PV on top of an existing PV like pvcreate does. */
 	pp.preserve_existing = 1;
 
-	/* pvcreate within vgcreate cannot be forced. */
-	pp.force = 0;
-
 	if (!vgcreate_params_set_defaults(cmd, &vp_def, NULL))
 		return EINVALID_CMD_LINE;
 	vp_def.vg_name = vg_name;


