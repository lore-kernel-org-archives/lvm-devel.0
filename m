From: Bryn Reeves <bmr@sourceware.org>
Date: Mon, 8 May 2017 12:18:45 -0400
Subject: master - dmfilemapd: always initialise 'same' local variable (Coverity)
Message-ID: <201705081618.v48GIjIE015765@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9940d16fe5251f2f1d7cb008cfd3be1bfb50120
Commit:        a9940d16fe5251f2f1d7cb008cfd3be1bfb50120
Parent:        c5fee2ee6e483ee9e56d842f402d2de9dfe5151a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon May 8 17:10:25 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon May 8 17:10:25 2017 +0100

dmfilemapd: always initialise 'same' local variable (Coverity)

Fix a regression introduced in 70bb726 that allows a local variable
in the monitored file checking routine to be accessed before its
assignment when the file has already been unlinked.
---
 daemons/dmfilemapd/dmfilemapd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index bbaabda..2637bd2 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -562,6 +562,7 @@ static int _filemap_monitor_check_file_unlinked(struct filemap_monitor *fm)
 	ssize_t len;
 
 	fm->deleted = 0;
+	same = 0;
 
 	if ((fd = open(fm->path, O_RDONLY)) < 0)
 		goto check_unlinked;


