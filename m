From: David Teigland <teigland@sourceware.org>
Date: Fri,  8 Apr 2022 16:34:12 +0000 (GMT)
Subject: main - lvmlockd: return error from vgcreate init_vg_sanlock
Message-ID: <20220408163412.0F8603858C51@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d14245c72425b99c3bc33a533da46962d010871a
Commit:        d14245c72425b99c3bc33a533da46962d010871a
Parent:        99f9bb28c9bf9cc5bda14674a3827ec5164b2872
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 8 11:28:53 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 8 11:34:04 2022 -0500

lvmlockd: return error from vgcreate init_vg_sanlock

in vgcreate for shared sanlock vg, if sanlock_write_resource
returns an unexpected error, then make init_vg_sanlock fail
which will cause the vgcreate to fail.
---
 daemons/lvmlockd/lvmlockd-sanlock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 3f078ea41..3f3ee14f3 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -684,10 +684,10 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 			break;
 		}
 
-		if (rv) {
+		if (rv < 0) {
 			log_error("clear lv resource area %llu error %d",
 				  (unsigned long long)offset, rv);
-			break;
+			return rv;
 		}
 		offset += align_size;
 	}

