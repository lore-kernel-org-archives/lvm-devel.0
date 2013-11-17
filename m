From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:19 +0000 (UTC)
Subject: master - dev-cache.c: Make dev_name a little more robust.
Message-ID: <20131117222719.7FF2161327@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5bb1b48eea704c5970a719d2e77577dccd82bb9
Commit:        a5bb1b48eea704c5970a719d2e77577dccd82bb9
Parent:        71b6565529028fcc075c52595fde380c96065cc9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Nov 17 22:34:56 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 22:34:56 2013 +0100

dev-cache.c: Make dev_name a little more robust.

---
 lib/device/dev-cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 46e5d65..9451314 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1036,6 +1036,6 @@ int dev_fd(struct device *dev)
 
 const char *dev_name(const struct device *dev)
 {
-	return (dev) ? dm_list_item(dev->aliases.n, struct str_list)->str :
+	return (dev && dev->aliases.n) ? dm_list_item(dev->aliases.n, struct str_list)->str :
 	    "unknown device";
 }


