From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:56:05 +0000 (UTC)
Subject: master - lvmetad: Initialise debug_config also if no -d is given.
Message-ID: <20120926175605.D8500A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f96286c29897ba9ac5c7c2f167d0f33ebaa93d4
Commit:        9f96286c29897ba9ac5c7c2f167d0f33ebaa93d4
Parent:        1ff2245c23247a1d3f9a03be66d3d186c824f03f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Sep 20 01:56:41 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

lvmetad: Initialise debug_config also if no -d is given.

---
 daemons/lvmetad/lvmetad-core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index f796e33..6c2303d 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1043,6 +1043,7 @@ int main(int argc, char *argv[])
 	s.pidfile = LVMETAD_PIDFILE;
 	s.protocol = "lvmetad";
 	s.protocol_version = 1;
+	ls.debug_config = "";
 
 	// use getopt_long
 	while ((opt = getopt(argc, argv, "?fhVd:Rs:")) != EOF) {


