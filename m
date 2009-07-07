From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  7 Jul 2009 00:24:24 -0400
Subject: [PATCH] Remove unneeded LOCK_NONBLOCKING from vg_read() API.
In-Reply-To: <1246940664-14890-4-git-send-email-dwysocha@redhat.com>
References: <1246940664-14890-1-git-send-email-dwysocha@redhat.com>
	<1246940664-14890-2-git-send-email-dwysocha@redhat.com>
	<1246940664-14890-3-git-send-email-dwysocha@redhat.com>
	<1246940664-14890-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1246940664-14890-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove unneeded LOCK_NONBLOCKING from vg_read() API and tools that
use it.  We no longer need this flag anywhere since we now automatically
set LCK_NONBLOCK inside lock_vol() if vgs_locked().
For further details, see:
commit d52b3fd3fe2006e2d13e42f8518b6512bff03710
Author: Dave Wysochanski <dwysocha@redhat.com>
Date:   Wed May 13 13:02:52 2009 +0000

    Remove NON_BLOCKING lock flag from tools and set a policy to auto-set.

    As a simplification to the tools and further liblvm, this patch pushes
    the setting of NON_BLOCKING lock flag inside the lock_vol() call.
    The policy we set is if any existing VGs are currently locked, we
    set the NON_BLOCKING flag.

At some point it may make sense to add this flag back if we get an
RFE from a liblvm user, but for now let's keep it as simple as
possible.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    3 ---
 lib/metadata/metadata.c          |    3 ---
 tools/vgextend.c                 |    2 +-
 tools/vgmerge.c                  |    3 +--
 tools/vgreduce.c                 |    2 +-
 tools/vgremove.c                 |    2 +-
 tools/vgsplit.c                  |    3 +--
 7 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 33eeae0..e49aa9c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -110,9 +110,6 @@ struct pv_segment;
 #define READ_ALLOW_EXPORTED	0x00020000U
 #define READ_REQUIRE_RESIZEABLE	0x00040000U
 
-/* FIXME Deduce these next requirements internally instead of having caller specify. */
-#define LOCK_NONBLOCKING	0x00000100U	/* Fail if not available immediately. */
-
 /* A meta-flag, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE 	0x00100000U
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 25c2795..449ac4c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2845,9 +2845,6 @@ vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
 	if (flags & READ_REQUIRE_RESIZEABLE)
 		status |= RESIZEABLE_VG;
 
-	if (flags & LOCK_NONBLOCKING)
-		lock_flags |= LCK_NONBLOCK;
-
 	return _vg_lock_and_read(cmd, vg_name, vgid, lock_flags, status, flags);
 }
 
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 1000dc2..a08d4db 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -43,7 +43,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL,
-				READ_REQUIRE_RESIZEABLE | LOCK_NONBLOCKING);
+				READ_REQUIRE_RESIZEABLE);
 	if (vg_read_error(vg)) {
 		vg_release(vg);
 		unlock_vg(cmd, VG_ORPHANS);
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 4a9e377..37f6bd7 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -35,8 +35,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
-				     LOCK_NONBLOCKING);
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
 	if (vg_read_error(vg_from)) {
 		vg_release(vg_from);
 		unlock_and_release_vg(cmd, vg_to, vg_name_to);
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 44010e3..b3b6dba 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -424,7 +424,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	vg->extent_count -= pv_pe_count(pv);
 
 	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
-				       NULL, LOCK_NONBLOCKING);
+				       NULL, 0);
 
 	if (vg_read_error(orphan_vg))
 		goto bad;
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 5956075..ff35720 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -41,7 +41,7 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	ret = process_each_vg(cmd, argc, argv,
-			      READ_FOR_UPDATE | LOCK_NONBLOCKING,
+			      READ_FOR_UPDATE,
 			      NULL, &vgremove_single);
 
 	unlock_vg(cmd, VG_ORPHANS);
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 0dc5bc4..6d6090b 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -341,8 +341,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (rc == FAILED_EXIST) {
 		existing_vg = 1;
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
-					   READ_REQUIRE_RESIZEABLE |
-					   LOCK_NONBLOCKING);
+					   READ_REQUIRE_RESIZEABLE);
 
 		if (vg_read_error(vg_to)) {
 			vg_release(vg_to);
-- 
1.6.0.6


