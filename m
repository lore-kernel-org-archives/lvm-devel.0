From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:32 +0000 (UTC)
Subject: master - dmeventd: mirror plugin update
Message-ID: <20151022213332.E64C2610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91350f5c6ad149a565402254688c6bd1700c5bf5
Commit:        91350f5c6ad149a565402254688c6bd1700c5bf5
Parent:        9c5c9e2355826ad3835f35e494dde9bb8b1e6356
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 17:09:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:28:37 2015 +0200

dmeventd: mirror plugin update

Don't use  --config  - this requires reload of lvm.conf
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 62ad331..e20b249 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -220,8 +220,7 @@ int register_device(const char *device,
 	}
 
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
-				   "lvconvert --config devices{ignore_suspended_devices=1} "
-				   "--repair --use-policies", device)) {
+				   "lvconvert --repair --use-policies", device)) {
 		dmeventd_lvm2_exit_with_pool(state);
 		goto_bad;
 	}


