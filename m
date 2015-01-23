From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 23 Jan 2015 20:33:00 +0000 (UTC)
Subject: master - devices: DASD doesn't need to be stackable.
Message-ID: <20150123203300.44CE960EC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e11d85c774084783520b5cc77e059cfa5e1b254
Commit:        3e11d85c774084783520b5cc77e059cfa5e1b254
Parent:        dab3ebce4c75e931345159dfcf906cc32a066541
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 23 20:32:31 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 23 20:32:31 2015 +0000

devices: DASD doesn't need to be stackable.

---
 lib/device/dev-type.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 389b0c8..dc8b61d 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -207,9 +207,6 @@ int dev_subsystem_part_major(struct dev_types *dt, struct device *dev)
 	if (MAJOR(dev->dev) == dt->emcpower_major)
 		return 1;
 
-	if (MAJOR(dev->dev) == dt->dasd_major)
-		return 1;
-
 	if (MAJOR(dev->dev) == dt->power2_major)
 		return 1;
 


