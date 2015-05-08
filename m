From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:48 +0000 (UTC)
Subject: master - debug: show sys errors
Message-ID: <20150508131648.CA55560E32@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eadebc3b615c8dec8f99f5e411b01c97b791987b
Commit:        eadebc3b615c8dec8f99f5e411b01c97b791987b
Parent:        ed2a08bf25e3b4e6a88c55402ab5dc11061ad68e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 11:38:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 15:15:10 2015 +0200

debug: show sys errors

---
 libdm/libdm-file.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index 26c8241..52f9d45 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -199,10 +199,10 @@ retry_fcntl:
 
 fail_close_unlink:
 	if (unlink(lockfile))
-		stack;
+		log_sys_debug("unlink", lockfile);
 fail_close:
 	if (close(fd))
-		stack;
+		log_sys_debug("close", lockfile);
 
 	return 0;
 }


