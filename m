From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 17:22:29 -0400
Subject: master - lvmlockd: improve error message for existing lockspace
Message-ID: <201805312122.w4VLMT9s001284@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=06b2e5c176b7a371efa62b27af2acb1e6f7984be
Commit:        06b2e5c176b7a371efa62b27af2acb1e6f7984be
Parent:        caa600a409fe811a25f2d784daeb6780ea977614
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 31 15:52:23 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 31 15:52:23 2018 -0500

lvmlockd: improve error message for existing lockspace

When a VG/lockspace already exists with the same name
don't just print the error number.
---
 lib/locking/lvmlockd.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 0af2b38..24a46e7 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -548,6 +548,9 @@ static int _init_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
 	case -EPROTONOSUPPORT:
 		log_error("VG %s init failed: lock manager dlm is not supported by lvmlockd", vg->name);
 		break;
+	case -EEXIST:
+		log_error("VG %s init failed: a lockspace with the same name exists", vg->name);
+		break;
 	default:
 		log_error("VG %s init failed: %d", vg->name, result);
 	}
@@ -671,6 +674,9 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 	case -EMSGSIZE:
 		log_error("VG %s init failed: no disk space for leases", vg->name);
 		break;
+	case -EEXIST:
+		log_error("VG %s init failed: a lockspace with the same name exists", vg->name);
+		break;
 	default:
 		log_error("VG %s init failed: %d", vg->name, result);
 	}


