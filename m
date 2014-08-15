From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:52 +0000 (UTC)
Subject: master - cleanup: quite gcc warn
Message-ID: <20140815130752.D970B60CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9534c21ead16dae8975fdaf1959b5534dc175f84
Commit:        9534c21ead16dae8975fdaf1959b5534dc175f84
Parent:        ff33d215ba488bc3abf7bb33f1c25ee1fc0e65c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 15 14:08:06 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:45 2014 +0200

cleanup: quite gcc warn

gcc can't see dev_get_primary_dev  returns only 0,1,2
so ensure 'name' is always defined in valid path.
---
 lib/filters/filter-mpath.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 52c9341..a933ba1 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -158,6 +158,7 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 		return 0;
 
 	switch (dev_get_primary_dev(dt, dev, &primary_dev)) {
+		default:
 		case 0:
 			/* Error. */
 			log_error("Failed to get primary device for %d:%d.", major, minor);


