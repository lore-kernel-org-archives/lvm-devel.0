From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 10 Mar 2017 11:53:20 -0500
Subject: master - libdm: use correct value for NR_FILEMAPD_ARGS
Message-ID: <201703101653.v2AGrKLH018530@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c6b8e90e34df6742cfb348ad9225cbdf6b51283
Commit:        8c6b8e90e34df6742cfb348ad9225cbdf6b51283
Parent:        c71374531414081aa2aad71317dac55fc024a0d5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Mar 10 16:52:27 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Mar 10 16:52:27 2017 +0000

libdm: use correct value for NR_FILEMAPD_ARGS

The argument count for the file mapping daemon needs to account
for the program's name in argv[0] to avoid indexing off the end
of the argument array.
---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index c83c27b..5fc4938 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4927,7 +4927,7 @@ dm_filemapd_mode_t dm_filemapd_mode_from_string(const char *mode_str)
 }
 
 #define DM_FILEMAPD "dmfilemapd"
-#define NR_FILEMAPD_ARGS 6
+#define NR_FILEMAPD_ARGS 7 /* includes argv[0] */
 /*
  * Start dmfilemapd to monitor the specified file descriptor, and to
  * update the group given by 'group_id' when the file's allocation


