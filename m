From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 1 Feb 2018 15:58:48 -0500
Subject: master - libdm: accept mirror status with userspace word in the line
Message-ID: <201802012058.w11Kwm5R018367@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d4d5bf3234e90fbef233a376d6306e08ac6bf8d
Commit:        4d4d5bf3234e90fbef233a376d6306e08ac6bf8d
Parent:        083c221cbebccd8ea893e87f17c69fba378d8645
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 1 20:53:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 1 21:56:07 2018 +0100

libdm: accept mirror status with userspace word in the line

Just making sure the parser will not stop - although greater level of
support needs to be added (Describing doc seems to be missing however).
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-targets.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5c6b888..bf3ae19 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.147 - 
 =====================================
+  Parsing mirror status accepts 'userspace' keyword in status.
   Introduce dm_malloc_aligned for page alignment of buffers.
 
 Version 1.02.146 - 18th December 2017
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index 990d275..8766789 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -508,6 +508,11 @@ int dm_get_status_mirror(struct dm_pool *mem, const char *params,
 	if (!(pos = _skip_fields(pos, argc)))
 		goto_out;
 
+	if (strncmp(pos, "userspace", 9) == 0) {
+		pos += 9;
+		/* FIXME: support status of userspace mirror implementation */
+	}
+
 	if (sscanf(pos, "%u %n", &argc, &used) != 1)
 		goto_out;
 	pos += used;


