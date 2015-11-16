From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:17:10 +0000 (UTC)
Subject: master - cleanup: add _free on error path
Message-ID: <20151116001710.57BD5601DE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a4676fea9808f348b9bbda46c03dce298eef6e5
Commit:        5a4676fea9808f348b9bbda46c03dce298eef6e5
Parent:        c3b292a4a9924d00da421d66d8281f8cd8efc3a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 6 23:55:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:16:11 2015 +0100

cleanup: add _free on error path

Just like with failing allocation above also _free(dev).

TODO: rework this to always use mempool and drop unneeded
comlexity we have in this function.
---
 lib/device/dev-cache.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index b9d4271..185b394 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -115,6 +115,7 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 			}
 			if (!(alias->str = _strdup(filename))) {
 				log_error("filename strdup failed");
+				_free(dev);
 				return NULL;
 			}
 		}


