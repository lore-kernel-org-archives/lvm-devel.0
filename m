From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Sep 2015 15:45:53 +0000 (UTC)
Subject: master - dmsetup: use noflush with force removal
Message-ID: <20150918154553.5633460DF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=791e76ff700304da574ce03e9762c880cd17e522
Commit:        791e76ff700304da574ce03e9762c880cd17e522
Parent:        e0d915a8733c690abc36f91f89cdcc542b35dc82
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 14:35:52 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:45:45 2015 +0200

dmsetup: use noflush with force removal

When user specifies '--force' with remove/remove_all/wipe_table
use '--noflush --nolockfs' resume flags, so the operation
will not block when device underneath is blocked.
---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 006421b..3669b85 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.109 - 
 ======================================
+  Use --noflush and --nolockfs when removing device with --force.
   Parse new Overflow status string for snapshot target.
   Check dir path components are valid if using dm_create_dir, error out if not.
   Fix /dev/mapper handling to remove dangling entries if symlinks are found.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8b7ad74..632c4ca 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  * Copyright (C) 2005-2007 NEC Corporation
  *
  * This file is part of the device-mapper userspace tools.
@@ -1923,6 +1923,10 @@ static int _error_device(CMD_ARGS)
 	if (!_task_run(dmt))
 		goto_bad;
 
+	if (_switches[FORCE_ARG])
+		/* Avoid hang on flushing with --force */
+		_switches[NOLOCKFS_ARG] = _switches[NOFLUSH_ARG] = 1;
+
 	if (!_simple(DM_DEVICE_RESUME, name, 0, 0)) {
 		_simple(DM_DEVICE_CLEAR, name, 0, 0);
 		goto_bad;


