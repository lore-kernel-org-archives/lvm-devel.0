From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:12 +0200
Subject: [PATCH 05/30] Print vg_name and do not to access vg->name
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <4ed74f138478e118c6a7e418aa638d72c913d4d3.1287994529.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang Logic error Dereference of null pointer
Replacing pointer access with vg_name.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/pvresize.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/pvresize.c b/tools/pvresize.c
index ccd025a..af499e5 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -148,7 +148,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	if (!is_orphan_vg(vg_name)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to store physical volume \"%s\" in "
-				  "volume group \"%s\"", pv_name, vg->name);
+				  "volume group \"%s\"", pv_name, vg_name);
 			goto out;
 		}
 		backup(vg);
-- 
1.7.3.1


