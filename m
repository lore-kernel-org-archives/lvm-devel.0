From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:09 +0000 (UTC)
Subject: master - cleanup: singlenode minor change
Message-ID: <20121215162509.76708AAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a266154e1fc598ae184780391dc8d8e87eb2c891
Commit:        a266154e1fc598ae184780391dc8d8e87eb2c891
Parent:        8ab43345051fe49b1d56771383feb65c408eaf9a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 14:01:19 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 14:57:40 2012 +0100

cleanup: singlenode minor change

Use strcpy instead of sprintf for plain string.
And use dm_strncpy for safer strncpy.

TODO: Fix API return values for cluster functions.
---
 daemons/clvmd/clvmd-singlenode.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index 3b35bf5..b968c5f 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -136,7 +136,7 @@ static int _csid_from_name(char *csid, const char *name)
 
 static int _name_from_csid(const char *csid, char *name)
 {
-	sprintf(name, "SINGLENODE");
+	strcpy(name, "SINGLENODE");
 	return 0;
 }
 
@@ -284,9 +284,8 @@ static int _cluster_send_message(const void *buf, int msglen,
 
 static int _get_cluster_name(char *buf, int buflen)
 {
-	strncpy(buf, "localcluster", buflen);
-	buf[buflen - 1] = 0;
-	return 0;
+	/* FIXME - cluster_ops API is broken - swap 1/0 */
+	return dm_strncpy(buf, "localcluster", buflen) ? 0 : 1;
 }
 
 static struct cluster_ops _cluster_singlenode_ops = {


