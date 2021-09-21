From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:51:01 +0000 (GMT)
Subject: main - gcc-fanalyzer: remove unneded zeroing
Message-ID: <20210921195101.A8B803858C3A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4ef8f7cde6ea481f96f101dc6189979cf3674cfe
Commit:        4ef8f7cde6ea481f96f101dc6189979cf3674cfe
Parent:        178df1c8f4aa6fa73f9f55f2a7f5f7b8c8c0964d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 18:09:45 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

gcc-fanalyzer: remove unneded zeroing

Since we zallocate array here, we don't need to set to NULL
and clean gcc warning about strdup leakage.
---
 daemons/dmeventd/dmeventd.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 46b3ff12f..d89ab4af8 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -2085,7 +2085,6 @@ static void _restart_dmeventd(void)
 		}
 		message += strlen(message) + 1;
 	}
-	_initial_registrations[count] = NULL;
 
 	if (version >= 2) {
 		if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_PARAMETERS, "-", "-", 0, 0)) {


