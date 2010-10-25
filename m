From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:29 +0200
Subject: [PATCH 22/30] Fix constness warning
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <f5ad4e42db829b60ebb0eebadb463720b43b0d71.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix usage of const 'data' pointer and also assign void* directly without
uneeded cast for C.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index a38fc4c..88291f7 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2399,7 +2399,7 @@ static int _dm_deps_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field, const void *data,
 			 void *private)
 {
-	struct dm_deps *deps = (struct dm_deps *) data;
+	const struct dm_deps *deps = data;
 	int i;
 	char buf[DM_MAX_TYPE_NAME], *repstr;
 
-- 
1.7.3.1


