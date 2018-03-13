From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:05:15 -0400
Subject: master - dmsetup: indent
Message-ID: <201803131205.w2DC5FOA002745@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b1ace8ce195046bddbbcdba08d87b7e9a741cdbc
Commit:        b1ace8ce195046bddbbcdba08d87b7e9a741cdbc
Parent:        e9cadbe105b7a449d98598a9329a170bce2d689e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 12 11:58:04 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

dmsetup: indent

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 0d5b713..eac3bb6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2473,7 +2473,7 @@ static int _status(CMD_ARGS)
 					printf("%s: ", name);
 			} else if (!matched) {
 				/*
- 				 * Before first target of device in concise output,
+				 * Before first target of device in concise output,
 				 * print basic device information in the appropriate format.
 				 * Separate devices by a semi-colon.
 				 */


