From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 24 Oct 2014 20:59:17 +0000 (UTC)
Subject: master - vg_read: Remove unused READ_WITHOUT_LOCK.
Message-ID: <20141024205917.41DF961176@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7916cae697aed7e9f8c286e4f9c6de3cb7ed5e88
Commit:        7916cae697aed7e9f8c286e4f9c6de3cb7ed5e88
Parent:        c3bb9629a8e1cd786fad33def773873008bdc413
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 24 21:54:04 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 24 21:54:04 2014 +0100

vg_read: Remove unused READ_WITHOUT_LOCK.

Unused since 67a7b7a87da65b2350f975272e581be5f41976e0:
  report: Iterate over labels instead of PVs for label-only reports.
(included in 2.02.105).
---
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/metadata.c          |    4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7467b64..d05333c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -145,7 +145,6 @@
 /* vg_read and vg_read_for_update flags */
 #define READ_ALLOW_INCONSISTENT	0x00010000U
 #define READ_ALLOW_EXPORTED	0x00020000U
-#define READ_WITHOUT_LOCK	0x00040000U
 #define READ_WARN_INCONSISTENT	0x00080000U
 
 /* A meta-flag, useful with toollib for_each_* functions. */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9308cb7..3e1b94a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4256,7 +4256,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 
 	already_locked = lvmcache_vgname_is_locked(vg_name);
 
-	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK) &&
+	if (!already_locked &&
 	    !lock_vol(cmd, vg_name, lock_flags, NULL)) {
 		log_error("Can't get lock for %s", vg_name);
 		return _vg_make_handle(cmd, vg, FAILED_LOCKING);
@@ -4330,7 +4330,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	return _vg_make_handle(cmd, vg, failure);
 
 bad:
-	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK))
+	if (!already_locked)
 		unlock_vg(cmd, vg_name);
 
 bad_no_unlock:


