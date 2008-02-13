From: Jim Meyering <jim@meyering.net>
Date: Wed, 13 Feb 2008 20:11:32 +0100
Subject: [PATCH] is_orphan: make parameter "const" to avoid compiler warning
Message-ID: <87abm4n02j.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Building lvm today, I saw this warning:

    display/display.c:310: warning: passing argument 1 of 'is_orphan'\
      discards qualifiers from pointer target type

Here's the fix I expect to commit:

---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f992b1d..22895de 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Avoid a compiler warning.
   Fix lvconvert detection of mirror conversion in progress. (2.02.30)
   Avoid automatic lvconvert polldaemon invocation when -R specified. (2.02.30)
   Fix 'pvs -a' to detect VGs of PVs without metadata areas.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f98c472..df70128 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -318,7 +318,7 @@ int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct list *mdas, int64_t label_sector);
 int is_pv(pv_t *pv);
 int is_orphan_vg(const char *vg_name);
-int is_orphan(pv_t *pv);
+int is_orphan(const pv_t *pv);
 int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_from,
 		       struct volume_group *vg_to);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 92c282c..640f874 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1975,7 +1975,7 @@ int is_orphan_vg(const char *vg_name)
  * is_orphan - Determine whether a pv is an orphan based on its vg_name
  * @pv: handle to the physical volume
  */
-int is_orphan(pv_t *pv)
+int is_orphan(const pv_t *pv)
 {
 	return is_orphan_vg(pv_field(pv, vg_name));
 }
--
1.5.4.1.35.g882c


