From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:49 +0000 (GMT)
Subject: main - cov: happier with defined extent_size
Message-ID: <20210310003649.24CC73857C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6097dfb9ad2faae1c28295b35e1fba82cb4b6f8b
Commit:        6097dfb9ad2faae1c28295b35e1fba82cb4b6f8b
Parent:        94712e3233ac7610ed74c3207c131ec7d9a843c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 19:28:24 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:35:02 2021 +0100

cov: happier with defined extent_size

Set extent_size with != 0 value so there is not division by 0
in any code path.
---
 tools/toollib.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/toollib.c b/tools/toollib.c
index b9be54ebb..3c81de26b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4006,6 +4006,7 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 	};
 
 	struct volume_group dummy_vg = {
+		.extent_size = 1,
 		.fid = &dummy_fid,
 		.name = "",
 		.system_id = (char *) "",


