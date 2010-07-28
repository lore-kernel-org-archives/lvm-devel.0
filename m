From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:57 +0200
Subject: [PATCH 11/14] Fix void* arithmetic and more readable char[]
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <d6c213114714ba98b47c33f93bd0a28bc1218ac4.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/mm/dbg_malloc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index 0add7b6..d86326d 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -196,12 +196,12 @@ int dm_dump_memory_debug(void)
 		for (c = 0; c < sizeof(str) - 1; c++) {
 			if (c >= mb->length)
 				str[c] = ' ';
-			else if (*(char *)(mb->magic + c) == '\0')
+			else if (((char *)mb->magic)[c] == '\0')
 				str[c] = '\0';
-			else if (*(char *)(mb->magic + c) < ' ')
+			else if (((char *)mb->magic)[c] < ' ')
 				str[c] = '?';
 			else
-				str[c] = *(char *)(mb->magic + c);
+				str[c] = ((char *)mb->magic)[c];
 		}
 		str[sizeof(str) - 1] = '\0';
 
-- 
1.7.2


