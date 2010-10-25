From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:13 +0200
Subject: [PATCH 06/30] Ensure we always have origin defined
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <95e3333c3c671cabbc5a99a2bfbbc15dcf948f32.1287994529.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang Logic error	Dereference of null pointer
Ensure the code path could not use origin == NULL because of internal
error in code.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvcreate.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index de5b59c..a9e3c2d 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -179,6 +179,10 @@ static int _update_extents_params(struct volume_group *vg,
 					  lp->origin);
 				return 0;
 			}
+			if (!origin) {
+				log_error(INTERNAL_ERROR "Couldn't find origin volume.");
+				return 0;
+			}
 			lp->extents = lp->extents * origin->le_count / 100;
 			break;
 		case PERCENT_NONE:
-- 
1.7.3.1


