From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 19 Aug 2016 13:55:24 +0000 (UTC)
Subject: master - lvcreate: Drop warning messages for number of raid stripes.
Message-ID: <20160819135524.E67AE61815@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e192fde6878a0e32316125b2e4c9813f4a95bede
Commit:        e192fde6878a0e32316125b2e4c9813f4a95bede
Parent:        ea0f604e704dc8418d962e20529fd1bcddf06bb7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 19 14:53:33 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 19 14:53:33 2016 +0100

lvcreate: Drop warning messages for number of raid stripes.

It's now just setting a default, not adjusting the user's parameter.
---
 tools/lvcreate.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index d3a64af..33664c5 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -470,8 +470,7 @@ static int _read_raid_params(struct cmd_context *cmd,
 					return 0;
 				}
 
-				log_warn("Adjusting stripes to the minimum of 2 for %s.",
-					 lp->segtype->name);
+				log_verbose("Using 2 stripes for %s.", lp->segtype->name);
 				lp->stripes = 2;
 			}
 
@@ -497,7 +496,7 @@ static int _read_raid_params(struct cmd_context *cmd,
 			return 0;
 		}
 
-		log_warn("Adjusting stripes to the minimum of 3 for %s.", lp->segtype->name);
+		log_verbose("Using 3 stripes for %s.", lp->segtype->name);
 		lp->stripes = 3;
 	} else if (lp->stripes < 2) {
 		if (lp->stripes_supplied) {
@@ -505,7 +504,7 @@ static int _read_raid_params(struct cmd_context *cmd,
 			return 0;
 		}
 
-		log_warn("Adjusting stripes to the minimum of 2 for %s.", lp->segtype->name);
+		log_verbose("Using 2 stripes for %s.", lp->segtype->name);
 		lp->stripes = 2;
 	}
 


