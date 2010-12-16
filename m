From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:14 +0100
Subject: [PATCH 06/20] Replace void* arithmetic with char*
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <6c8ab2db0ea297ec7142f999786a4a8fbffaa97c.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |    2 +-
 tools/dmsetup.c         |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8e7a22f..5510977 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -399,7 +399,7 @@ int target_version(const char *target_name, uint32_t *maj,
 			goto out;
 		}
 
-		target = (void *) target + target->next;
+		target = (struct dm_versions *)((char *) target + target->next);
 	} while (last_target != target);
 
       out:
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 1a56d24..56f1579 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1288,8 +1288,8 @@ static int _process_all(int argc, char **argv, int silent,
 	}
 
 	do {
-		names = (void *) names + next;
-		if (!fn(argc, argv, (void *) names))
+		names = (struct dm_names *)((char *) names + next);
+		if (!fn(argc, argv, names))
 			r = 0;
 		next = names->next;
 	} while (next);
@@ -1632,7 +1632,7 @@ static int _targets(int argc __attribute__((unused)), char **argv __attribute__(
 		printf("%-16s v%d.%d.%d\n", target->name, target->version[0],
 		       target->version[1], target->version[2]);
 
-		target = (void *) target + target->next;
+		target = (struct dm_versions *)((char *) target + target->next);
 	} while (last_target != target);
 
 	r = 1;
-- 
1.7.3.3


