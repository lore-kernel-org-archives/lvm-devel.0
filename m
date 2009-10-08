From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Thu,  8 Oct 2009 14:49:12 +0200
Subject: [PATCH 05/11] debian: keep libdm-abi consistent
In-Reply-To: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
References: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
Message-ID: <58b1e4d3fbc50afac900c970b6d1fa6819391946.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Fabio M. Di Nitto <fdinitto@redhat.com>

don't change the ABI of libdm on selinux enable, just make the selinux
function a NOP

Also noted by Alasdair that some other feature set affects the libdm ABI.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 e412cff... 6e4f91a... M	lib/activate/fs.c
:100644 100644 175d8d1... 248d3ac... M	libdm/libdm-common.c
 lib/activate/fs.c    |    2 --
 libdm/libdm-common.c |    6 ++----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index e412cff..6e4f91a 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -201,10 +201,8 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 		return 0;
 	}
 
-#ifdef HAVE_SELINUX
 	if (!dm_set_selinux_context(lv_path, S_IFLNK))
 		return_0;
-#endif
 
 	return 1;
 }
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 175d8d1..248d3ac 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -373,9 +373,9 @@ int dm_task_add_target(struct dm_task *dmt, uint64_t start, uint64_t size,
 	return 1;
 }
 
-#ifdef HAVE_SELINUX
 int dm_set_selinux_context(const char *path, mode_t mode)
 {
+#ifdef HAVE_SELINUX
 	security_context_t scontext;
 
 	if (is_selinux_enabled() <= 0)
@@ -396,9 +396,9 @@ int dm_set_selinux_context(const char *path, mode_t mode)
 	}
 
 	freecon(scontext);
+#endif
 	return 1;
 }
-#endif
 
 static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 			 uid_t uid, gid_t gid, mode_t mode)
@@ -445,10 +445,8 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 
 	log_debug("Created %s", path);
 
-#ifdef HAVE_SELINUX
 	if (!dm_set_selinux_context(path, S_IFBLK))
 		return 0;
-#endif
 
 	return 1;
 }
-- 
1.5.4.3


