From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 May 2016 15:21:31 +0000 (UTC)
Subject: master - cleanup: drop tracing
Message-ID: <20160506152131.6935760F6C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2842a645fdb66ce1f90cad1fd206912eef365059
Commit:        2842a645fdb66ce1f90cad1fd206912eef365059
Parent:        db606591c0b8aa173661377be066be7bd78c5351
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 6 13:59:13 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 6 16:48:16 2016 +0200

cleanup: drop tracing

When activation is disabled, avoid tracing it in cache target.
---
 lib/cache_segtype/cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 0cbb993..9d56f32 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -230,7 +230,7 @@ static int _target_present(struct cmd_context *cmd,
 	const char *str;
 
 	if (!activation())
-		return_0;
+		return 0;
 
 	if (!_cache_checked) {
 		_cache_checked = 1;


