From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 26 Oct 2010 14:59:25 +0200
Subject: [PATCH 4/5] Fix theoretical usage of NULL pointer dereference
In-Reply-To: <cover.1288097372.git.zkabelac@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
Message-ID: <a1cfd7e4e519a821b545e3a299eb01866ed76877.1288097372.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Make sure we have *c defined.
clang seems to be happier with this check.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/regex/ttree.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/libdm/regex/ttree.c b/libdm/regex/ttree.c
index ec97c98..a384c59 100644
--- a/libdm/regex/ttree.c
+++ b/libdm/regex/ttree.c
@@ -97,6 +97,12 @@ int ttree_insert(struct ttree *tt, unsigned int *key, void *data)
 			}
 		}
 	}
+
+	if (!*c) {
+		log_error(INTERNAL_ERROR "Insert failed.");
+		return 0;
+	}
+
 	(*c)->data = data;
 
 	return 1;
-- 
1.7.3.2


