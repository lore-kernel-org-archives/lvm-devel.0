From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:51 -0500
Subject: master - hints: fix mem leaking buffers
Message-ID: <62049.119111412074602475@us-mta-277.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c38be0653111e3d63efbbf2f8914c83f15a73e70
Commit:        c38be0653111e3d63efbbf2f8914c83f15a73e70
Parent:        1349a52626610abc6bfc20871e592c050048380d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 18:00:54 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

hints: fix mem leaking buffers

---
 lib/label/hints.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index df1327a..8739f33 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -1200,6 +1200,8 @@ check:
 			return;
 		}
 	}
+
+	free(name);
 }
 
 /*
@@ -1353,6 +1355,9 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 		  dm_list_size(devs_out), dm_list_size(devs_in));
 
 	dm_list_splice(hints_out, &hints_list);
+
+	free(vgname);
+
 	return 1;
 }
 



