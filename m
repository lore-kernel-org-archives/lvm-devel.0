From: Milan Broz <mbroz@redhat.com>
Date: Mon, 28 Dec 2009 21:21:06 +0100
Subject: [PATCH 1/4] Properly decode flags even for VG locks.
Message-ID: <1262031669-26458-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

And decode flags in humar readable form in client.
And clean some trailing whitespaces.

No eal change n this patch (only debugging messages changed).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/lvm-functions.c |   71 +++++++++++++++++++++--------------------
 lib/locking/cluster_locking.c |   13 ++++---
 2 files changed, 43 insertions(+), 41 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 385aa86..c832ec5 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -74,23 +74,23 @@ static const char *decode_locking_cmd(unsigned char cmdl)
 	const char *command;
 
 	switch (cmdl & LCK_TYPE_MASK) {
-	case LCK_NULL:   
-		type = "NULL";   
+	case LCK_NULL:
+		type = "NULL";
 		break;
-	case LCK_READ:   
-		type = "READ";   
+	case LCK_READ:
+		type = "READ";
 		break;
-	case LCK_PREAD:  
-		type = "PREAD";  
+	case LCK_PREAD:
+		type = "PREAD";
 		break;
-	case LCK_WRITE:  
-		type = "WRITE";  
+	case LCK_WRITE:
+		type = "WRITE";
 		break;
-	case LCK_EXCL:   
-		type = "EXCL";   
+	case LCK_EXCL:
+		type = "EXCL";
 		break;
-	case LCK_UNLOCK: 
-		type = "UNLOCK"; 
+	case LCK_UNLOCK:
+		type = "UNLOCK";
 		break;
 	default:
 		type = "unknown";
@@ -98,34 +98,35 @@ static const char *decode_locking_cmd(unsigned char cmdl)
 	}
 
 	switch (cmdl & LCK_SCOPE_MASK) {
-	case LCK_VG: 
-		scope = "VG"; 
+	case LCK_VG:
+		scope = "VG";
+		command = "LCK_VG";
 		break;
-	case LCK_LV: 
+	case LCK_LV:
 		scope = "LV"; 
+		switch (cmdl & LCK_MASK) {
+		case LCK_LV_EXCLUSIVE & LCK_MASK:
+			command = "LCK_LV_EXCLUSIVE";
+			break;
+		case LCK_LV_SUSPEND & LCK_MASK:
+			command = "LCK_LV_SUSPEND";
+			break;
+		case LCK_LV_RESUME & LCK_MASK:
+			command = "LCK_LV_RESUME";
+			break;
+		case LCK_LV_ACTIVATE & LCK_MASK:
+			command = "LCK_LV_ACTIVATE";
+			break;
+		case LCK_LV_DEACTIVATE & LCK_MASK:
+			command = "LCK_LV_DEACTIVATE";
+			break;
+		default:
+			command = "unknown";
+			break;
+		}
 		break;
 	default:
 		scope = "unknown";
-		break;
-	}
-
-	switch (cmdl & LCK_MASK) {
-	case LCK_LV_EXCLUSIVE & LCK_MASK:
-		command = "LCK_LV_EXCLUSIVE";  
-		break;
-	case LCK_LV_SUSPEND & LCK_MASK:    
-		command = "LCK_LV_SUSPEND";    
-		break;
-	case LCK_LV_RESUME & LCK_MASK:     
-		command = "LCK_LV_RESUME";     
-		break;
-	case LCK_LV_ACTIVATE & LCK_MASK:   
-		command = "LCK_LV_ACTIVATE";   
-		break;
-	case LCK_LV_DEACTIVATE & LCK_MASK: 
-		command = "LCK_LV_DEACTIVATE"; 
-		break;
-	default:
 		command = "unknown";
 		break;
 	}
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index d3138f2..225795a 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -450,12 +450,13 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 		return 0;
 	}
 
-	log_very_verbose("Locking %s %s %s %s%s%s%s (0x%x)", lock_scope, lockname,
-			 lock_type,
-			 flags & LCK_NONBLOCK ? "" : "B",
-			 flags & LCK_HOLD ? "H" : "",
-			 flags & LCK_LOCAL ? "L" : "",
-			 flags & LCK_CLUSTER_VG ? "C" : "",
+	log_very_verbose("Locking %s %s %s (%s%s%s%s%s%s) (0x%x)", lock_scope, lockname,
+			 lock_type, lock_scope,
+			 flags & LCK_NONBLOCK ? "|NONBLOCK" : "",
+			 flags & LCK_HOLD ? "|HOLD" : "",
+			 flags & LCK_LOCAL ? "|LOCAL" : "",
+			 flags & LCK_CLUSTER_VG ? "|CLUSTER" : "",
+			 flags & LCK_CACHE ? "|CACHE" : "",
 			 flags);
 
 	/* Send a message to the cluster manager */
-- 
1.6.5.7


