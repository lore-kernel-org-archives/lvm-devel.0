From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 18 Jul 2016 17:50:04 +0000 (UTC)
Subject: master - dmstats: check uuid, major, and alldevices before argc (Coverity)
Message-ID: <20160718175004.0AC7260158@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2bf6742f845df13bae39ae157cfabf44252c570
Commit:        d2bf6742f845df13bae39ae157cfabf44252c570
Parent:        252952ff339bd928cc4e5ed34958d2845365b397
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jul 18 18:28:07 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Jul 18 18:48:34 2016 +0100

dmstats: check uuid, major, and alldevices before argc (Coverity)

The --uuid, --major and --alldevices arguments were incorrectly tested
after confirming argc is > 0, in a branch that only executes if argc
== 0 (i.e. they were unreachable).

Move all device checks before the test for argc and log an appropriate
error before returning.
---
 tools/dmsetup.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index a282572..985f63b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4978,24 +4978,24 @@ static int _stats_create_file(CMD_ARGS)
 		return 0;
 	}
 
+	if (_switches[UUID_ARG] || _switches[MAJOR_ARG]) {
+		log_error("--uuid and --major are incompatible with --filemap.");
+		return 0;
+	}
+
+	if (_switches[ALL_DEVICES_ARG]) {
+		log_error("--alldevices is incompatible with --filemap.");
+		return 0;
+	}
+
 	/* _stats_create_file does not use _process_all() */
-	if (names || !argc) {
+	if (!argc) {
 		log_error("--filemap requires a file path argument");
 		return 0;
-	} else {
-		if (argc)
-			path = argv[0];
-		else {
-			if (_switches[UUID_ARG] || _switches[MAJOR_ARG])
-				log_error("--uuid and --major are incompatible "
-					  "with --filemap.");
-			if (_switches[ALL_DEVICES_ARG])
-				log_error("--alldevices is incompatible with "
-					  "--filemap.");
-			return 0;
-		}
 	}
 
+	path = argv[0];
+
 	if (_switches[PRECISE_ARG]) {
 		if (!dm_stats_driver_supports_precise()) {
 			log_error("Using --precise requires driver version "


