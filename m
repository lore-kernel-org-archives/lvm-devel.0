From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:52 +0000 (UTC)
Subject: master - cleanup: verbose in human readable size
Message-ID: <20140702084852.7C5DA61054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=165cfab7db386942162f819d247ce64ab5436119
Commit:        165cfab7db386942162f819d247ce64ab5436119
Parent:        6b3a49876eb36b5b97e7fbd7935208f0d85607e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 1 11:03:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:42 2014 +0200

cleanup: verbose in human readable size

Use normal size like we use everywhere else.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a6187a0..085fdcd 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -446,7 +446,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 				  "range 4K to 512K");
 			return 0;
 		}
-		log_verbose("Setting chunksize to %d sectors.", lp->chunk_size);
+		log_verbose("Setting chunk size to %s.", display_size(cmd, lp->chunk_size));
 
 		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
 			return_0;


