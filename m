From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 14:47:00 +0100
Subject: [PATCH 07/25] Replicator: extend VG with list of opened vgs
In-Reply-To: <cover.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
Message-ID: <a3659426c881df34280c487330634d2b1c1da590.1268833246.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add linked list of opened VGs and counter for missing VGs.
Needed for replicator target.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index cc4221e..ac0681e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -250,6 +250,10 @@ struct volume_group {
 
 	struct dm_list tags;
 
+        /* List of locked and opened VGs */
+	struct dm_list vgs;
+	uint32_t missing_vgs;
+
 	/*
 	 * FIXME: Move the next fields into a different struct?
 	 */
-- 
1.7.0.1


