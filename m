From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Mar 2015 13:31:37 +0000 (UTC)
Subject: master - cleanup: add stack trace
Message-ID: <20150306133137.E4DAD606F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a2ae250ffc52c7620ec837cb10eb7b9ca44a121
Commit:        6a2ae250ffc52c7620ec837cb10eb7b9ca44a121
Parent:        60427d5d429b88d1c6cd13f90794f9b50dc366e6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 6 11:12:16 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 6 13:51:54 2015 +0100

cleanup: add stack trace

Missed stack in error path.
---
 lib/format_text/import.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 4b02264..fe19dd7 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -100,7 +100,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	if ((!dev && !config_file_read(cft)) ||
 	    (dev && !config_file_read_fd(cft, dev, offset, size,
 					 offset2, size2, checksum_fn, checksum)))
-		goto out;
+		goto_out;
 
 	/*
 	 * Find a set of version functions that can read this file


