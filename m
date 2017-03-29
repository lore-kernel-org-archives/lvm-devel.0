From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:17 -0400
Subject: master - dmfilemapd: always terminate link buffer after readlink(2) (coverity)
Message-ID: <201703292016.v2TKGHw7000769@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7db51a6bed8704ec634b44b4c5bd1dc35fdae86b
Commit:        7db51a6bed8704ec634b44b4c5bd1dc35fdae86b
Parent:        70bb72667889a2d6f250437e5db247eb111ca1aa
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 17:16:34 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:34:05 2017 +0100

dmfilemapd: always terminate link buffer after readlink(2) (coverity)

---
 daemons/dmfilemapd/dmfilemapd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 3fd76b7..6e25c5c 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -593,6 +593,7 @@ check_unlinked:
 			  getpid(), fm->fd);
 		return 0;
 	}
+	link_buf[len] = '\0';
 
 	/*
 	 * Try to re-open the file, from the path now reported in /proc/pid/fd.


