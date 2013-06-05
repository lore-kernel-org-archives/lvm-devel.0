From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:01:46 +0000 (UTC)
Subject: dev-mornfall-lvmcache - libdm: improve check in dm_split_lvm_name
Message-ID: <20130605120146.41B53613B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f1dd00c3634d111be9a42524ab50b2f31962530
Commit:        8f1dd00c3634d111be9a42524ab50b2f31962530
Parent:        a2b76a6f022920abd59072decfa7d3d76eeda913
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 12:48:24 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:10:43 2013 +0200

libdm: improve check in dm_split_lvm_name

We support both type of call - with or without mem pool.
So ensure we will not use NULL vgname also when mem is given.
---
 libdm/libdm-string.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 5ef6334..9d667bb 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -92,7 +92,10 @@ static char *_unquote(char *component)
 int dm_split_lvm_name(struct dm_pool *mem, const char *dmname,
 		      char **vgname, char **lvname, char **layer)
 {
-	if (mem && !(*vgname = dm_pool_strdup(mem, dmname)))
+	if (mem)
+		*vgname = dm_pool_strdup(mem, dmname);
+
+	if (!*vgname)
 		return 0;
 
 	_unquote(*layer = _unquote(*lvname = _unquote(*vgname)));


