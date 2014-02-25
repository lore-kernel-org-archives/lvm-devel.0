From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Feb 2014 08:44:50 +0000 (UTC)
Subject: master - mirror: move declaration to define
Message-ID: <20140225084450.6222C61268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=502213e06ca8d30eaa957c284802c0bff4cb8940
Commit:        502213e06ca8d30eaa957c284802c0bff4cb8940
Parent:        962af71b7635ead2bc4449a1dd0bd4d4a2b46b07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 25 09:35:26 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 25 09:35:26 2014 +0100

mirror: move declaration to define

For compilation without cmirrord hide unused vars.
(in-release update)
---
 lib/mirror/mirrored.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 57c6bba..5088173 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -465,8 +465,6 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 	uint32_t maj, min, patchlevel;
 	unsigned maj2, min2, patchlevel2;
 	char vsn[80];
-	struct utsname uts;
-	unsigned kmaj, kmin, krel;
 
 	if (!_mirrored_checked) {
 		_mirrored_checked = 1;
@@ -501,6 +499,8 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 		 * contact.
 		 */
 		if (dm_daemon_is_running(CMIRRORD_PIDFILE)) {
+			struct utsname uts;
+			unsigned kmaj, kmin, krel;
 			/*
 			 * The dm-log-userspace module was added to the
 			 * 2.6.31 kernel.


