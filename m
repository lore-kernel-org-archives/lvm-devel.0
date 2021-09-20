From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:52 +0000 (GMT)
Subject: main - gcc-fanalyzer: better losetup error path
Message-ID: <20210920132952.E9C5F3858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=951263865603dd9b431c8625c8feefe216cf0c74
Commit:        951263865603dd9b431c8625c8feefe216cf0c74
Parent:        3e21c8524e8b31e61fe4db99664319e2823f1a53
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 18 21:00:49 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 13:58:57 2021 +0200

gcc-fanalyzer: better losetup error path

Fix leaking memory on error path on _process_losetup_switches().
However real impact is close to zero as dm-loop target isn't really used.
---
 libdm/dm-tools/dmsetup.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index a3d1248bc..f431f7509 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -6762,6 +6762,8 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 	if (!_table ||
 	    !_loop_table(_table, (size_t) LOOP_TABLE_SIZE, loop_file, device_name, offset)) {
 		log_error("Could not build device-mapper table for %s.", (*argvp)[0]);
+		free(loop_file);
+		free(_table);
 		free(device_name);
 		return 0;
 	}
@@ -6770,6 +6772,7 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 	_command = "create";
 	(*argvp)[0] = device_name ;
 	*argcp = 1;
+	free(loop_file);
 
 	return 1;
 }


