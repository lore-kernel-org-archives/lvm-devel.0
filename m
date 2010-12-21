From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:43 +0100
Subject: [PATCH 11/23] Add stack traces for archive
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <8e65221ff43e45ac07575de210fa14538bff13cd.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If archive of back_locally fails - add stack trace.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/archiver.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index ef85c6c..3d291c8 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -452,9 +452,12 @@ void check_current_backup(struct volume_group *vg)
 	log_suppress(old_suppress);
 
 	if (vg_backup) {
-		archive(vg_backup);
+		if (!archive(vg_backup))
+			stack;
 		free_vg(vg_backup);
 	}
-	archive(vg);
-	backup_locally(vg);
+	if (!archive(vg))
+		stack;
+	if (!backup_locally(vg))
+		stack;
 }
-- 
1.7.3.4


