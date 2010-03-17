From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 14:46:54 +0100
Subject: [PATCH 01/25] Remove const from volume_group* in process_each
In-Reply-To: <cover.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
Message-ID: <6a34f3f1453baa96dfac7024ddfedb2034ba32a0.1268833246.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

struct volume_group could change as a result of process_single()
so vg is not const.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |    2 +-
 tools/toollib.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 0d3fe0a..972d077 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -83,7 +83,7 @@ char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
  * Metadata iteration functions
  */
 int process_each_lv_in_vg(struct cmd_context *cmd,
-			  const struct volume_group *vg,
+			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
 			  void *handle,
diff --git a/tools/toollib.h b/tools/toollib.h
index 4743fd5..d284de4 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -76,7 +76,7 @@ typedef int (*process_single_lv_fn_t) (struct cmd_context *cmd,
 				  void *handle);
 
 int process_each_lv_in_vg(struct cmd_context *cmd,
-			  const struct volume_group *vg,
+			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
 			  void *handle,
-- 
1.7.0.1


