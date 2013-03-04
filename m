From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 4 Mar 2013 18:34:10 -0500 (EST)
Subject: [PATCH] dmsetup: check errors
Message-ID: <Pine.LNX.4.64.1303041833190.621@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

dmsetup: check errors

atoll doesn't check for errors, so invalid sector numbers were silently
accepted in the "dmsetup message" command.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 tools/dmsetup.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: LVM2.2.02.98/tools/dmsetup.c
===================================================================
--- LVM2.2.02.98.orig/tools/dmsetup.c	2013-01-30 20:14:03.000000000 +0100
+++ LVM2.2.02.98/tools/dmsetup.c	2013-01-30 20:15:30.000000000 +0100
@@ -770,6 +770,8 @@ static int _message(CMD_ARGS)
 	size_t sz = 1;
 	struct dm_task *dmt;
 	char *str;
+	uint64_t sector;
+	char *endptr;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TARGET_MSG)))
 		return 0;
@@ -784,7 +786,12 @@ static int _message(CMD_ARGS)
 		argv++;
 	}
 
-	if (!dm_task_set_sector(dmt, (uint64_t) atoll(argv[1])))
+	sector = strtoull(argv[1], &endptr, 10);
+	if (*endptr || endptr == argv[1]) {
+		err("invalid sector");
+		goto out;
+	}
+	if (!dm_task_set_sector(dmt, sector))
 		goto out;
 
 	argc -= 2;


