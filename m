From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:12 +0000 (UTC)
Subject: master - clvmd: release excl_uuid hash
Message-ID: <20120823124212.85143A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=59ca324c35f3898070a5ad4cb0ec267a1eb4a292
Commit:        59ca324c35f3898070a5ad4cb0ec267a1eb4a292
Parent:        ed53b4b6740973411acee52a31fca9c48c585dab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 16 20:26:46 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:34:56 2012 +0200

clvmd: release excl_uuid hash

Release allocated hash before exit.
---
 daemons/clvmd/clvmd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 4efa237..f74490a 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -371,7 +371,8 @@ int main(int argc, char *argv[])
 
 		case 'R':
 			check_permissions();
-			return refresh_clvmd(1)==1?0:1;
+			ret = (refresh_clvmd(1) == 1) ? 0 : 1;
+			goto out;
 
 		case 'S':
 			check_permissions();


