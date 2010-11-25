From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:08 +0100
Subject: [PATCH 04/29] Reset vg pointer after release
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <dabe05f0262b06b4e8b7010375de674ea01a89c1.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Set vg to NULL after releasing it as the following memlock() test may
lead to goto for the second call of vg_release() with the same vg pointer.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 780b806..743d633 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3117,6 +3117,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 			return vg;
 		}
 		vg_release(vg);
+		vg = NULL; /* reset so memlock goto out is safe */
 	}
 
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
-- 
1.7.3.2


