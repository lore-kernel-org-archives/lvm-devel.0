From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 22 Oct 2019 07:32:41 -0400
Subject: stable-2.02 - dm: Fix compilation of dmsetup
Message-ID: <201910221132.x9MBWfpF025391@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c65f3fd8dfaae6efd8529a846c6f2a9f604c440d
Commit:        c65f3fd8dfaae6efd8529a846c6f2a9f604c440d
Parent:        c24fa7b7b714871950e0366ca4c35d0e601786ff
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Oct 21 16:31:53 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Oct 22 10:37:40 2019 +0200

dm: Fix compilation of dmsetup

Fix: 889c88e9dab33195efc4dc0400a4b0aaa3383948
---
 libdm/libdevmapper.h |    2 +-
 tools/dmsetup.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 81c67dc..18fe9f9 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -123,7 +123,7 @@ enum {
 
 	DM_DEVICE_ARM_POLL,
 
-	DM_GET_TARGET_VERSION
+	DM_DEVICE_GET_TARGET_VERSION
 };
 
 /*
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index dfa9e34..b5419ca 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2595,7 +2595,7 @@ static int _target_version(CMD_ARGS)
 	struct dm_task *dmt;
 	struct dm_versions *target;
 
-	if (!(dmt = dm_task_create(DM_GET_TARGET_VERSION)))
+	if (!(dmt = dm_task_create(DM_DEVICE_GET_TARGET_VERSION)))
 		return_0;
 
 	if (!dm_task_set_name(dmt, argv[0]))


