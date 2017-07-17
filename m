From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:56 -0400
Subject: master - dev-cache: avoid hashing same data again
Message-ID: <201707171140.v6HBeuDF022618@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=767a5e1281ed436a11af90e0249bd59a5fbd40c8
Commit:        767a5e1281ed436a11af90e0249bd59a5fbd40c8
Parent:        9b4b5d449ef7045d33b8d8d7e69011d16f4bb8ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 20:56:58 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:33:17 2017 +0200

dev-cache: avoid hashing same data again

Before hashing device again with path, check if it's not already hashed.

TODO: maybe bigger chunk of executed code might be actually skipped.
---
 lib/device/dev-cache.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 06d44ce..9a4dbc9 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -706,6 +706,12 @@ static int _insert_dev(const char *path, dev_t d)
 		}
 	}
 
+	if (dm_hash_lookup(_cache.names, path) == dev) {
+		/* Hash already has matching entry present */
+		log_debug("Path already cached %s.", path);
+		return 1;
+	}
+
 	if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
 		log_error("Failed to duplicate path string.");
 		return 0;


