From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:01 -0400
Subject: master - cov: fix leaking openned file descriptors
Message-ID: <201810151555.w9FFt1SD020524@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2ab784440a2cbde7448a3f5e315f7e8a8cbcf729
Commit:        2ab784440a2cbde7448a3f5e315f7e8a8cbcf729
Parent:        9b85ecb85b2875bd6743a97147355218879aef3a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:34:31 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: fix leaking openned file descriptors

Once the FD is no longer needed, close it.
---
 tools/pvscan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index a4c0244..fd75362 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -216,6 +216,8 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 		}
 
 		rv = read(fd, buf_in, sizeof(buf_in));
+		if (close(fd))
+			log_sys_debug("close", path);
 		if (!rv || rv < 0) {
 			log_debug("Failed to read %s", path);
 			continue;


