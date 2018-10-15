From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:35 -0400
Subject: master - cov: dm node message fix missing initilization
Message-ID: <201810151555.w9FFtZf7020638@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cbbdace00610ae25a5db8a7156b7d3a2779e4e0b
Commit:        cbbdace00610ae25a5db8a7156b7d3a2779e4e0b
Parent:        253989ecd953b1afcaea43fa0515c55bc6533cd2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 15:24:51 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: dm node message fix missing initilization

In 2 teoretical error path the 'r' value has not been set to
proper value before possible use in error path.
---
 device_mapper/libdm-deptree.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index f49675c..26251f8 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -1487,7 +1487,7 @@ static int _node_message(uint32_t major, uint32_t minor,
 			 int expected_errno, const char *message)
 {
 	struct dm_task *dmt;
-	int r;
+	int r = 0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TARGET_MSG)))
 		return_0;


