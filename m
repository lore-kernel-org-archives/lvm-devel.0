From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:13 +0000 (UTC)
Subject: master - cleanup: clvmd use else if
Message-ID: <20140310112713.1A51A603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c44ede31a39598c30634ff7b20e45e4600df5d37
Commit:        c44ede31a39598c30634ff7b20e45e4600df5d37
Parent:        2cfe0840d2e33fd8aa1892aaf73498fac68040af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 8 22:57:31 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:09 2014 +0100

cleanup: clvmd use else if

When string already matches, skip rest of tests.
---
 daemons/clvmd/clvmd.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 0a8d591..43fecb6 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -2352,13 +2352,13 @@ static if_type_t parse_cluster_interface(char *ifname)
 
 	if (!strcmp(ifname, "auto"))
 		iface = IF_AUTO;
-	if (!strcmp(ifname, "cman"))
+	else if (!strcmp(ifname, "cman"))
 		iface = IF_CMAN;
-	if (!strcmp(ifname, "openais"))
+	else if (!strcmp(ifname, "openais"))
 		iface = IF_OPENAIS;
-	if (!strcmp(ifname, "corosync"))
+	else if (!strcmp(ifname, "corosync"))
 		iface = IF_COROSYNC;
-	if (!strcmp(ifname, "singlenode"))
+	else if (!strcmp(ifname, "singlenode"))
 		iface = IF_SINGLENODE;
 
 	return iface;


