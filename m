From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 14 Nov 2014 17:17:32 +0000 (UTC)
Subject: master - vg_read: use new error flag
Message-ID: <20141114171732.B7DF260DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06e3f1757eee0005267bbe1e088dd95638540849
Commit:        06e3f1757eee0005267bbe1e088dd95638540849
Parent:        01bbbc27bf7734ca81fa4dba6a497af1d8a66ad3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 14 14:55:57 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 14 18:09:27 2014 +0100

vg_read: use new error flag

Failed recovery provides different (NULL) VG then FAILED_INCONSISTENT.
Mark it with different failure bit - since FAILED_INCONSISTENT is
supposed to contain something 'usable' (thought inconsistent).
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |    2 +-
 3 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 19f029b..4b526fa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.113 - 
 =====================================
+  Failed recovery returns FAILED_RECOVERY status flag for vg_read().
   Exit with non-zero status code when pvck encounters a problem.
   Fix clean_tree after activation/resume for cache target (2.02.112).
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 375f7be..c472f41 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -162,6 +162,7 @@
 #define FAILED_CLUSTERED	0x00000040U
 #define FAILED_ALLOCATION	0x00000080U
 #define FAILED_EXIST		0x00000100U
+#define FAILED_RECOVERY		0x00000200U
 #define SUCCESS			0x00000000U
 
 #define VGMETADATACOPIES_ALL UINT32_MAX
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 11dabcc..601a766 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4359,7 +4359,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		if (!(vg = _recover_vg(cmd, vg_name, vgid))) {
 			log_error("Recovery of volume group \"%s\" failed.",
 				  vg_name);
-			failure |= FAILED_INCONSISTENT;
+			failure |= FAILED_RECOVERY;
 			goto bad_no_unlock;
 		}
 	}


