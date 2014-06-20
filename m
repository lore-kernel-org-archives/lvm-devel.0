From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jun 2014 09:24:14 +0000 (UTC)
Subject: master - memlock: skip more entries
Message-ID: <20140620092414.276876019A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32ad8ab5a4a6cd00f15beb947568a7a5b702f545
Commit:        32ad8ab5a4a6cd00f15beb947568a7a5b702f545
Parent:        59ed4d3bf6b1aaf7c3db837251c60ff9004f0879
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 20 11:10:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 20 11:13:41 2014 +0200

memlock: skip more entries

Add more entries for memlock skipping - since those are never
used by lvm code in critical section (suspend state).
---
 lib/mm/memlock.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 84b93db..7d9a8f3 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -100,8 +100,10 @@ static const char * const _blacklist_maps[] = {
 	"/libselinux.so.",	/* not using selinux during mlock */
 	"/libsepol.so.",	/* not using sepol during mlock */
 	"/libtinfo.so.",	/* not using tinfo during mlock */
-	"/libuuid.so.",	/* not using uuid during mlock (blkid) */
+	"/libudev.so.",		/* not using udev during mlock */
+	"/libuuid.so.",		/* not using uuid during mlock (blkid) */
 	"/libdl-",		/* not using dlopen,dlsym during mlock */
+	"/etc/selinux",		/* not using selinux during mlock */
 	/* "/libdevmapper-event.so" */
 };
 


