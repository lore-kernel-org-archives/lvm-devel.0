From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Mar 2010 17:17:09 +0200
Subject: [PATCH 08/22] Replicator: extend volume_group with list of VGs
In-Reply-To: <cover.1269961680.git.zkabelac@redhat.com>
References: <cover.1269961680.git.zkabelac@redhat.com>
Message-ID: <287a8a585c7ec71a98a89c35cea9ac8cb65bbec9.1269961680.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add linked list of opened VGs. List keeps the information
about needed and locked and opened VGs for replicator target.
Also add missing_vgs status information for quick check and
also for possible continuos process_each_lv() where we need
to detect whether failure has been caused by missing VG or
some other reason.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6b36731..eee71b2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -250,6 +250,10 @@ struct volume_group {
 
 	struct dm_list tags;
 
+        /* List of wanted/locked and opened VGs */
+	struct dm_list vgs;
+	uint32_t missing_vgs;
+
 	/*
 	 * FIXME: Move the next fields into a different struct?
 	 */
-- 
1.7.0.1


