From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:35:57 +0100
Subject: [PATCH 6/6] Cleanup const compiler warning in _comp_area
In-Reply-To: <cover.1263389392.git.zkabelac@redhat.com>
References: <cover.1263389392.git.zkabelac@redhat.com>
Message-ID: <6b13a9aaf67f5706ba71e6d5125ea216e6045bd7.1263389392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e54c453..583cc3f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -852,8 +852,8 @@ static int _for_each_pv(struct cmd_context *cmd, struct logical_volume *lv,
 
 static int _comp_area(const void *l, const void *r)
 {
-	const struct pv_area *lhs = *((const struct pv_area **) l);
-	const struct pv_area *rhs = *((const struct pv_area **) r);
+	const struct pv_area *lhs = *((const struct pv_area * const *) l);
+	const struct pv_area *rhs = *((const struct pv_area * const *) r);
 
 	if (lhs->count < rhs->count)
 		return 1;
-- 
1.6.6


