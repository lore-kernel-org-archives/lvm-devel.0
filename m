From: David Teigland <teigland@sourceware.org>
Date: Mon, 18 Jan 2021 22:26:56 +0000 (GMT)
Subject: main - label_scan: fix missing free of filtered_devs
Message-ID: <20210118222656.4C1533890409@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2ec29d0677a5f92728873b5b1e303478cd71a3e4
Commit:        2ec29d0677a5f92728873b5b1e303478cd71a3e4
Parent:        9757b4726c6f1e16c84210a3c4578db29eb7662d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jan 18 16:26:02 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 18 16:26:02 2021 -0600

label_scan: fix missing free of filtered_devs

missing free of devl entries on filtered_devs list in
commit 2c9bb676048fda86867df165aa297f7078dffc4b
---
 lib/label/label.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/lib/label/label.c b/lib/label/label.c
index e067a6bed..e6dd4a17e 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1243,6 +1243,11 @@ int label_scan(struct cmd_context *cmd)
 		free(devl);
 	}
 
+	dm_list_iterate_items_safe(devl, devl2, &filtered_devs) {
+		dm_list_del(&devl->list);
+		free(devl);
+	}
+
 	/*
 	 * If hints were not available/usable, then we scanned all devs,
 	 * and we now know which are PVs.  Save this list of PVs we've


