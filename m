From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:46 +0100
Subject: [PATCH 14/23] Add stack trace for backup and backup_remove
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <80140cb22b102c7bb6fbefd5e04fe1ba937e2789.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add missing 'stack' traces for errors.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |    3 ++-
 tools/vgrename.c        |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5f75a66..27abaea 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -611,7 +611,8 @@ int vg_remove(struct volume_group *vg)
 		}
 	}
 
-	backup_remove(vg->cmd, vg->name);
+	if (!backup_remove(vg->cmd, vg->name))
+		stack;
 
 	if (ret)
 		log_print("Volume group \"%s\" successfully removed", vg->name);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 98be9a9..6739ebb 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -164,8 +164,10 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 		}
 	}
 
-	backup(vg);
-	backup_remove(cmd, vg_name_old);
+	if (!backup(vg))
+                stack;
+	if (!backup_remove(cmd, vg_name_old))
+                stack;
 
 	unlock_vg(cmd, vg_name_new);
 	unlock_and_free_vg(cmd, vg, vg_name_old);
-- 
1.7.3.4


