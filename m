From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:04 +0000 (GMT)
Subject: main - cov: better handle reallocation of adapt_file
Message-ID: <20210920133004.396EE3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=376e7072323bc394341c7b9a43a7ca51c2b9e400
Commit:        376e7072323bc394341c7b9a43a7ca51c2b9e400
Parent:        ce907bcd26f4814966a814771f9c1d01c80c9b01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 19 20:24:35 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: better handle reallocation of adapt_file

If the option would be given more then once.
---
 daemons/lvmlockd/lvmlockd-core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 35c9b6c25..701372220 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -6305,6 +6305,7 @@ int main(int argc, char *argv[])
 		case '0':
 			break;
 		case 128:
+			free((void *) adopt_file);
 			adopt_file = strdup(optarg);
 			break;
 		case 'h':


