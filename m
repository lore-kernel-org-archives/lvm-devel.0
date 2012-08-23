From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 22 Aug 2012 21:35:28 -0400 (EDT)
Subject: [PATCH] check sector number in dmsetup message
In-Reply-To: <Pine.LNX.4.64.1208222122180.7091@file.rdu.redhat.com>
References: <Pine.LNX.4.64.1208151832280.8587@file.rdu.redhat.com>
	<20120816070955.GA32526@agk-dp.fab.redhat.com>
	<C3B343EE19BD2940B6AEC40C9BE99426094C0C@AUSX10MPS302.AMER.DELL.COM>
	<Pine.LNX.4.64.1208201429110.18279@file.rdu.redhat.com>
	<20120821163329.GA21395@freewill.lab.equallogic.com>
	<Pine.LNX.4.64.1208212103310.1653@file.rdu.redhat.com>
	<20120822192547.GJ32571@agk-dp.fab.redhat.com>
	<Pine.LNX.4.64.1208221813380.12623@file.rdu.redhat.com>
	<20120822222708.GN32571@agk-dp.fab.redhat.com>
	<Pine.LNX.4.64.1208222122180.7091@file.rdu.redhat.com>
Message-ID: <Pine.LNX.4.64.1208222133590.8956@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

atoll doesn't check for errors, so invalid sector numbers were silently
accepted in the "dmsetup message" command.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 tools/dmsetup.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: LVM2.2.02.96/tools/dmsetup.c
===================================================================
--- LVM2.2.02.96.orig/tools/dmsetup.c	2012-08-23 03:27:51.000000000 +0200
+++ LVM2.2.02.96/tools/dmsetup.c	2012-08-23 03:29:48.000000000 +0200
@@ -769,6 +769,8 @@ static int _message(CMD_ARGS)
 	size_t sz = 1;
 	struct dm_task *dmt;
 	char *str;
+	uint64_t sector;
+	char *endptr;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TARGET_MSG)))
 		return 0;
@@ -783,7 +785,12 @@ static int _message(CMD_ARGS)
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


