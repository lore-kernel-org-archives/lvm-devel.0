From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:30 +0000 (UTC)
Subject: master - cleanup: remove extra braces
Message-ID: <20130205134730.EE941A0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7ea12f222bb40d0bdd523a6072c5771053f75c1
Commit:        d7ea12f222bb40d0bdd523a6072c5771053f75c1
Parent:        6d74ff2bf8313dae0cc27530eebf63be06a7bae6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 4 20:31:56 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:27:24 2013 +0100

cleanup: remove extra braces

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 196c170..8b1145f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3672,7 +3672,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		}
 		if (ind == INACTIVE_ARG)
 		       _switches[INACTIVE_ARG]++;
-		if ((ind == MANGLENAME_ARG)) {
+		if (ind == MANGLENAME_ARG) {
 			_switches[MANGLENAME_ARG]++;
 			if (!strcasecmp(optarg, "none"))
 				_int_args[MANGLENAME_ARG] = DM_STRING_MANGLING_NONE;


