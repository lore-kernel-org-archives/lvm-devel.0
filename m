From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:16 +0100
Subject: [PATCH 08/20] Use const char * for name and old_name in vg
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <2dcef398948bb7111e271c87b561973b3417a255.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Turn pointers to const char - to avoid changes of these struct
members. (Having better control over, were the members could
be modified).

Idea for future: system_id should be probably  char[NAME_LEN]

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/vg.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index eb9debc..448dcfe 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -43,8 +43,8 @@ struct volume_group {
 	uint64_t status;
 
 	struct id id;
-	char *name;
-	char *old_name;		/* Set during vgrename and vgcfgrestore */
+	const char *name;
+	const char *old_name;		/* Set during vgrename and vgcfgrestore */
 	char *system_id;
 
 	uint32_t extent_size;
-- 
1.7.3.3


