From: Bryn Reeves <bmr@sourceware.org>
Date: Mon, 13 Mar 2017 07:49:34 -0400
Subject: master - dmfilemapd: return error for wrong number of args
Message-ID: <201703131149.v2DBnYIY015276@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b0aba5fe9e6b22b85d7f6ff9f8fdef09db61bce
Commit:        9b0aba5fe9e6b22b85d7f6ff9f8fdef09db61bce
Parent:        66760f9673659f0b3d52e9d7013bc69147101d9b
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Mar 13 11:09:11 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Mar 13 11:09:11 2017 +0000

dmfilemapd: return error for wrong number of args

The initial check on argc incorrectly returns 1 when the wrong
number of arguments are present, causing a segfault in main()
when no arguments are given:

  # dmfilemapd
  Wrong number of arguments.
  usage: dmfilemapd <fd> <group_id> <path> <mode> [<foreground>[<log_level>]]
  Segmentation fault (core dumped)
---
 daemons/dmfilemapd/dmfilemapd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 6d7c09f..4f20466 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -255,7 +255,7 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 	if (argc < 5) {
 		_early_log("Wrong number of arguments.");
 		_early_log("usage: %s", _usage);
-		return 1;
+		return 0;
 	}
 
 	memset(fm, 0, sizeof(*fm));


