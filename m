From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  6 Oct 2021 13:47:48 +0000 (GMT)
Subject: main - debug: fix stack tracing
Message-ID: <20211006134748.ADDBC385C409@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b7e9ec0cbf55e4a4e1f027be49bf45b11beb5a76
Commit:        b7e9ec0cbf55e4a4e1f027be49bf45b11beb5a76
Parent:        e30f3c84109b7e131da2497965aee83d73c604e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 1 13:44:17 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 6 15:39:58 2021 +0200

debug: fix stack tracing

Emit stack trace only on log_error path, and avoid on 'expected'
not-found path.
---
 lib/metadata/metadata.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b3c8c6ece..f29e73c7c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5015,7 +5015,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		unlock_vg(cmd, NULL, vg_name);
 		log_error("VG name not found for vgid %s", vgid);
 		failure |= FAILED_NOTFOUND;
-		goto_bad;
+		goto bad;
 	}
 
 	/*
@@ -5037,7 +5037,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		if (!(vg_read_flags & READ_OK_NOTFOUND))
 			log_error("Volume group \"%s\" not found", vg_name);
 		failure |= FAILED_NOTFOUND;
-		goto_bad;
+		goto bad;
 	}
 
 	/*
@@ -5053,7 +5053,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		if (!(vg_read_flags & READ_OK_NOTFOUND))
 			log_error("Volume group \"%s\" not found.", vg_name);
 		failure |= FAILED_NOTFOUND;
-		goto_bad;
+		goto bad;
 	}
 
 	/*
@@ -5264,7 +5264,7 @@ bad:
 
 		/* caller must unlock_vg and release_vg */
 		*error_vg = vg;
-		return_NULL;
+		return NULL;
 	}
 
 	if (vg) {


