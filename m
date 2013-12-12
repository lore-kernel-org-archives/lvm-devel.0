From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:43:30 +0000 (UTC)
Subject: master - cleanup: remove duplicate code
Message-ID: <20131212124330.8E7D76024C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c2cc2f794f540c0efead257bb8f8f1d909a053c
Commit:        1c2cc2f794f540c0efead257bb8f8f1d909a053c
Parent:        30a81e59894ed6c1fdb4a3bb0823b58de1e431cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 30 11:30:33 2011 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:28:19 2013 +0100

cleanup: remove duplicate code

As dev_name_confirmed() has check for DEV_REGULAR
remove this duplicated extra check prior its call.
---
 lib/device/dev-io.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 6c8613c..1d35a8f 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -446,9 +446,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		log_verbose("dev_open(%s) called while suspended",
 			    dev_name(dev));
 
-	if (dev->flags & DEV_REGULAR)
-		name = dev_name(dev);
-	else if (!(name = dev_name_confirmed(dev, quiet)))
+	if (!(name = dev_name_confirmed(dev, quiet)))
 		return_0;
 
 #ifdef O_DIRECT_SUPPORT


