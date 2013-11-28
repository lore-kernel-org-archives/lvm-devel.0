From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 28 Nov 2013 19:17:05 +0000 (UTC)
Subject: master - lvmetad: Add newline to missing socket error mesg
Message-ID: <20131128191705.55DF3602F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3074560eb36d0b1c8ec61f50e71b0b27dbda982
Commit:        b3074560eb36d0b1c8ec61f50e71b0b27dbda982
Parent:        3f8083107ea901f9c58ef38ad9bb8084825a2f88
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Nov 28 19:16:25 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Nov 28 19:16:25 2013 +0000

lvmetad: Add newline to missing socket error mesg

---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cd63144..6aac94a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Append missing newline to lvmetad missing socket path error message.
   Check for non-zero aligment in _text_pv_add_metadata_area() to not div by 0.
   Add allocation/use_blkid_wiping to lvm.conf to enable blkid wiping.
   Add configure --enable-blkid_wiping to use libblkid to detect signatures.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 7e64d9d..71254f4 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1242,7 +1242,7 @@ int main(int argc, char *argv[])
 
 	if (s.foreground) {
 		if (!_socket_override) {
-			fprintf(stderr, "A socket path (-s) is required in foreground mode.");
+			fprintf(stderr, "A socket path (-s) is required in foreground mode.\n");
 			exit(2);
 		}
 


