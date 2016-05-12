From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 12 May 2016 00:56:15 +0000 (UTC)
Subject: master - lvmetad: Fix client error when socket access fails.
Message-ID: <20160512005615.6AA3460EF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6203657a0bf4b15017724a8212cc61a8672afa5
Commit:        a6203657a0bf4b15017724a8212cc61a8672afa5
Parent:        e6cafdad3608f58bc0cea6a73b16d9728fb92181
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu May 12 01:54:09 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu May 12 01:54:09 2016 +0100

lvmetad: Fix client error when socket access fails.

---
 lib/cache/lvmetad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 391cbc4..9f7bf32 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -178,7 +178,7 @@ int lvmetad_socket_present(void)
 	int r;
 
 	if ((r = access(socket, F_OK)) && errno != ENOENT)
-		log_sys_error("lvmetad_socket_present", "");
+		log_sys_error("access", socket);
 
 	return !r;
 }


