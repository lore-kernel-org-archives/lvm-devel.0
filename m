From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:26 +0100
Subject: [PATCH 18/20] Remove dead assignment in _remove
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <3f4bd971a96d2cf811a0d80cdfedc85ddf21d39d.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'r' is not read - remove it.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/dmsetup.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 56f1579..ae223d6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1386,10 +1386,8 @@ error:
 
 static int _remove(int argc, char **argv, void *data __attribute__((unused)))
 {
-	int r;
-
 	if (_switches[FORCE_ARG] && argc > 1)
-		r = _error_device(argc, argv, NULL);
+		_error_device(argc, argv, NULL);
 
 	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
 }
-- 
1.7.3.3


