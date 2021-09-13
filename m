From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:14 +0000 (GMT)
Subject: main - cov: initilized more struct members
Message-ID: <20210913103614.DBD643858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5f1cdfa70ad2ec907fba8b9f5d0c1a251571c80
Commit:        f5f1cdfa70ad2ec907fba8b9f5d0c1a251571c80
Parent:        a8ee13900db58b018e143fbf6a3435c7803e82fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 9 23:07:40 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cov: initilized more struct members

For some hypothetical path, make these vars defined.
---
 tools/toollib.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/toollib.c b/tools/toollib.c
index 9d488c5a7..3bb04f92c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4010,6 +4010,8 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 	};
 
 	struct volume_group dummy_vg = {
+		.cmd = cmd,
+		.vgmem = cmd->mem,
 		.extent_size = 1,
 		.fid = &dummy_fid,
 		.name = "",


