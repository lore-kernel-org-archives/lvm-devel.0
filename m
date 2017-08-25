From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Aug 2017 08:24:56 -0400
Subject: master - dmsetup: validate strtol reading
Message-ID: <201708251224.v7PCOuZk005101@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=962874bfe2a3c3511e42fe29f0f013c780f65e63
Commit:        962874bfe2a3c3511e42fe29f0f013c780f65e63
Parent:        47b7d4a7336fa60eb25ad15b2fc3fcb5b96ce1c2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 25 11:48:17 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 25 14:20:59 2017 +0200

dmsetup: validate strtol reading

Better validation for --mode option.
---
 tools/dmsetup.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 341522c..d9532fb 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -7054,7 +7054,13 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		if (c == 'M' || ind == MODE_ARG) {
 			_switches[MODE_ARG]++;
 			/* FIXME Accept modes as per chmod */
-			_int_args[MODE_ARG] = (int) strtol(optarg, NULL, 8);
+			errno = 0;
+			_int_args[MODE_ARG] = (int) strtol(optarg, &s, 8);
+			if (errno || !s || *s || !_int_args[MODE_ARG]) {
+				log_error("Invalid argument for --mode: %s. %s",
+					  optarg, errno ? strerror(errno) : "");
+				return 0;
+			}
 		}
 		if (ind == DEFERRED_ARG)
 			_switches[DEFERRED_ARG]++;


