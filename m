From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:17 +0200
Subject: [PATCH 10/30] Fix potential NULL pointer dereference
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <0fe6e9c0c86a7a0487fb7a6eead6fc7b4760a123.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Makes clang happier as it covers all code paths and avoids NULL pointer
dereference through com pointer (which is NULL by default static
initialisation).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvm.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvm.c b/tools/lvm.c
index 60f9a79..9cac23e 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -85,11 +85,11 @@ static char *_list_args(const char *text, int state)
 				break;
 			}
 		}
-
-		if (!com)
-			return NULL;
 	}
 
+	if (!com)
+		return NULL;
+
 	/* Short form arguments */
 	if (len < 3) {
 		while (match_no < com->num_args) {
-- 
1.7.3.1


