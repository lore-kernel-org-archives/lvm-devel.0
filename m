From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Aug 2017 08:24:09 -0400
Subject: master - lvmlockctl: fix check for failing close
Message-ID: <201708251224.v7PCO9fL005049@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=da9a8fdedc25645706ae198bad098f366351db58
Commit:        da9a8fdedc25645706ae198bad098f366351db58
Parent:        288e10cf8b990cd740fba409d6f20525209f4f43
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 25 11:57:49 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 25 14:20:59 2017 +0200

lvmlockctl: fix check for failing close

On  close() failure it's -1.
---
 daemons/lvmlockd/lvmlockctl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 7d4e072..436221d 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -379,7 +379,7 @@ static int setup_dump_socket(void)
 	rv = bind(s, (struct sockaddr *) &dump_addr, dump_addrlen);
 	if (rv < 0) {
 		rv = -errno;
-		if (!close(s))
+		if (close(s))
 			log_error("failed to close dump socket");
 		return rv;
 	}


