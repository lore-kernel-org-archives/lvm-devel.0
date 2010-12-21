From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:47 +0100
Subject: [PATCH 15/23] Add test check for find_config_str
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <0b3634555ba5dfe0300d98e5da7511faa13dcbc5.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It looks like there should be some error code returned from _read_desc
when something fails.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/import_vsn1.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index e5e83d4..5a2d664 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -842,9 +842,9 @@ static void _read_desc(struct dm_pool *mem,
 	old_suppress = log_suppress(1);
 	d = find_config_str(cft->root, "description", "");
 	log_suppress(old_suppress);
-	*desc = dm_pool_strdup(mem, d);
+	*desc = (d) ? dm_pool_strdup(mem, d) : NULL;
 
-	get_config_uint32(cft->root, "creation_time", &u);
+	(void) get_config_uint32(cft->root, "creation_time", &u);
 	*when = u;
 }
 
-- 
1.7.3.4


