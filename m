From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:40 +0100
Subject: [PATCH 08/23] Fix memory leak in error path of restart_clvmd
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <77fc998c298a741d2b27dc40cba311d1ef157069.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Minor memory leak in debug mode.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 95d924b..b1ea9fa 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -406,6 +406,7 @@ out:
 	for (i = 0; i < argc && argv[i]; i++)
 		free(argv[i]);
 	free(argv);
+	free(debug_arg);
 
 	return 0;
 }
-- 
1.7.3.4


