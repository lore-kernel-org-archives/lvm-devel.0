From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:18 +0200
Subject: [PATCH 11/30] Fix theoretical usage of NULL pointer dereference
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <35485b7f7c5850e5a8bd1cb934f7a01efbf6fd46.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang seems to be happier with this check.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/regex/ttree.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/libdm/regex/ttree.c b/libdm/regex/ttree.c
index ec97c98..0ad40bd 100644
--- a/libdm/regex/ttree.c
+++ b/libdm/regex/ttree.c
@@ -97,7 +97,9 @@ int ttree_insert(struct ttree *tt, unsigned int *key, void *data)
 			}
 		}
 	}
-	(*c)->data = data;
+
+	if (*c)
+		(*c)->data = data;
 
 	return 1;
 }
-- 
1.7.3.1


