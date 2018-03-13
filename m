From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:03:50 -0400
Subject: master - dmsetup: use stderr for error output
Message-ID: <201803131203.w2DC3owo002274@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b7834af17ba17f4c478937ac5cb022045bb782b
Commit:        3b7834af17ba17f4c478937ac5cb022045bb782b
Parent:        29b2cfba06ee849774025c50599edb1c7587b7d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 9 23:29:09 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

dmsetup: use stderr for error output

When dmsetup command returns error, the message goes to stderr.
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index cc47d11..a394c3f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2191,7 +2191,7 @@ static int _error_device(CMD_ARGS)
 	name = names ? names->name : argv[0];
 
 	if (!name || !*name) {
-		printf("No device specified\n");
+		err("No device specified.");
 		return_0;
 	}
 		


