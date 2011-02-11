From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:30:57 +0100
Subject: [PATCH 11/16] const - static merge to const patch
In-Reply-To: <cover.1297419991.git.zkabelac@redhat.com>
References: <cover.1297419991.git.zkabelac@redhat.com>
Message-ID: <fba30c51c606d6feeef539436300210dc646c27b.1297419991.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/uuid/uuid.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index edcb1ba..c85b822 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -158,7 +158,7 @@ int id_write_format(const struct id *id, char *buffer, size_t size)
 {
 	int i, tot;
 
-	static unsigned group_size[] = { 6, 4, 4, 4, 4, 4, 6 };
+	static const unsigned group_size[] = { 6, 4, 4, 4, 4, 4, 6 };
 
 	assert(ID_LEN == 32);
 
-- 
1.7.4


