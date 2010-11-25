From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:27 +0100
Subject: [PATCH 23/29] Add test and error message for failure case
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <5383deb0c0a91b2eb3b1e57309eea5bc64fee8d2.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index ec98c3d..06be3c2 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -288,7 +288,8 @@ static const char *decode_cmd(unsigned char cmdl)
 
 static void remove_lockfile(void)
 {
-	unlink(CLVMD_PIDFILE);
+	if (unlink(CLVMD_PIDFILE))
+		log_sys_error("unlink", CLVMD_PIDFILE);
 }
 
 /*
-- 
1.7.3.2


