From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 08 Feb 2010 14:17:16 +0100
Subject: [PATCH] Suppress locking initialisation failure messages when --ignorelockingfailure is used
Message-ID: <4B700EDC.7020505@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We should not show error messages about locking initialisation failures when it is expected
and --ignorelockingfailure option is used (rhbz #561938).

Peter


diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 54e5e25..db70433 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -237,7 +237,8 @@ int init_locking(int type, struct cmd_context *cmd)
 				 _blocking_supported ? "" : "Non-blocking ");
 
 		if (!init_file_locking(&_locking, cmd)) {
-			log_error("File-based locking initialisation failed.");
+			if (!ignorelockingfailure())
+				log_error("File-based locking initialisation failed.");
 			break;
 		}
 		return 1;
@@ -264,7 +265,8 @@ int init_locking(int type, struct cmd_context *cmd)
 	case 3:
 		log_very_verbose("Cluster locking selected.");
 		if (!init_cluster_locking(&_locking, cmd)) {
-			log_error("Internal cluster locking initialisation failed.");
+			if (!ignorelocking_failure())
+				log_error("Internal cluster locking initialisation failed.");
 			break;
 		}
 		return 1;
@@ -291,7 +293,7 @@ int init_locking(int type, struct cmd_context *cmd)
 			  "be inaccessible.");
 		if (init_file_locking(&_locking, cmd))
 			return 1;
-		else
+		else if (!ignorelockingfailure())
 			log_error("File-based locking initialisation failed.");
 	}
 


