From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:15 +0000 (UTC)
Subject: master - dmeventd: drop duplicated code
Message-ID: <20131122200915.853DB61133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=879ea38c53f81ab22225fb368e8787144517d963
Commit:        879ea38c53f81ab22225fb368e8787144517d963
Parent:        1ff53bb7b682a13e32d986e53a40eeb8fb5e47c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 10:01:52 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:55 2013 +0100

dmeventd: drop duplicated code

Do not call pthread_attr_init() twice.
The second call has all proper tests.
---
 daemons/dmeventd/dmeventd.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index e9fc59b..189d1b6 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -273,7 +273,6 @@ static int _pthread_create_smallstack(pthread_t *t, void *(*fun)(void *), void *
 	int r;
 	pthread_t tmp;
 	pthread_attr_t attr;
-	pthread_attr_init(&attr);
 
 	/*
 	 * From pthread_attr_init man page:


