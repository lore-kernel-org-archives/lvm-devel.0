From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:11 -0500
Subject: master - coverity: missing free on error path
Message-ID: <201802282022.w1SKMBYM009728@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9bfc8881cb712a6b164f08ca3d70ec99745e6c22
Commit:        9bfc8881cb712a6b164f08ca3d70ec99745e6c22
Parent:        32bcdd90ae7c847e7b4fc5cc5184c581a4f6484a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 25 16:17:42 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:05:18 2018 +0100

coverity: missing free on error path

---
 daemons/dmfilemapd/dmfilemapd.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index aa50242..7519799 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -802,7 +802,7 @@ bad:
 	return 1;
 }
 
-static const char * _mode_names[] = {
+static const char * const _mode_names[] = {
 	"inode",
 	"path"
 };
@@ -827,8 +827,10 @@ int main(int argc, char **argv)
 		 "mode=%s, path=%s", fm.fd, fm.group_id,
 		 _mode_names[fm.mode], fm.path);
 
-	if (!_foreground && !_daemonise(&fm))
+	if (!_foreground && !_daemonise(&fm)) {
+		dm_free(fm.path);
 		return 1;
+	}
 
 	return _dmfilemapd(&fm);
 }


