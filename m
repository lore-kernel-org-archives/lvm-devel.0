From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jun 2008 14:24:29 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c daemons/ ...
Message-ID: <20080605142429.2141.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-05 14:24:28

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	daemons/clvmd  : lvm-functions.c clvmd.c 

Log message:
	Decode numbers in clvmd debugging output.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.883&r2=1.884
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/WHATS_NEW	2008/06/05 13:38:30	1.883
+++ LVM2/WHATS_NEW	2008/06/05 14:24:27	1.884
@@ -9,6 +9,7 @@
 
 Version 2.02.37 - 
 =================================
+  Decode numbers in clvmd debugging output.
   Add missing deactivation after activation failure in lvcreate -Zy.
   When activating, if precommitted metadata is still cached, assume it's live.
   When removing LV symlinks, skip any where the VG name is not determined.
--- LVM2/lib/cache/lvmcache.c	2008/06/05 13:06:39	1.53
+++ LVM2/lib/cache/lvmcache.c	2008/06/05 14:24:28	1.54
@@ -506,7 +506,8 @@
 		return_NULL;
 	}
 
-	log_debug("Using cached metadata for VG %s.", vginfo->vgname);
+	log_debug("Using cached %smetadata for VG %s.",
+		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
 
 	return vg;
 }
--- LVM2/daemons/clvmd/lvm-functions.c	2008/05/09 19:26:58	1.42
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/06/05 14:24:28	1.43
@@ -61,6 +61,95 @@
 	int lock_mode;
 };
 
+static const char *decode_locking_cmd(unsigned char cmdl)
+{
+	static char buf[128];
+	const char *type;
+	const char *scope;
+	const char *command;
+
+	switch (cmdl & LCK_TYPE_MASK) {
+	case LCK_NULL:   
+		type = "NULL";   
+		break;
+	case LCK_READ:   
+		type = "READ";   
+		break;
+	case LCK_PREAD:  
+		type = "PREAD";  
+		break;
+	case LCK_WRITE:  
+		type = "WRITE";  
+		break;
+	case LCK_EXCL:   
+		type = "EXCL";   
+		break;
+	case LCK_UNLOCK: 
+		type = "UNLOCK"; 
+		break;
+	default:
+		type = "unknown";
+		break;
+	}
+
+	switch (cmdl & LCK_SCOPE_MASK) {
+	case LCK_VG: 
+		scope = "VG"; 
+		break;
+	case LCK_LV: 
+		scope = "LV"; 
+		break;
+	default:
+		scope = "unknown";
+		break;
+	}
+
+	switch (cmdl) {
+	case LCK_LV_EXCLUSIVE:  
+		command = "LCK_LV_EXCLUSIVE";  
+		break;
+	case LCK_LV_SUSPEND:    
+		command = "LCK_LV_SUSPEND";    
+		break;
+	case LCK_LV_UNLOCK:        
+		command = "LCK_LV_UNLOCK";     
+		break;
+	case LCK_LV_RESUME:     
+		command = "LCK_LV_RESUME";     
+		break;
+	case LCK_LV_ACTIVATE:   
+		command = "LCK_LV_ACTIVATE";   
+		break;
+	case LCK_LV_DEACTIVATE: 
+		command = "LCK_LV_DEACTIVATE"; 
+		break;
+	default:
+		command = "unknown";
+		break;
+	}
+
+	sprintf(buf, "0x%x %s (%s|%s%s%s%s%s%s)", cmdl, command, type, scope,
+		cmdl & LCK_NONBLOCK   ? "|NONBLOCK" : "",
+		cmdl & LCK_HOLD       ? "|HOLD" : "",
+		cmdl & LCK_LOCAL      ? "|LOCAL" : "",
+		cmdl & LCK_CLUSTER_VG ? "|CLUSTER_VG" : "",
+		cmdl & LCK_CACHE      ? "|CACHE" : "");
+
+	return buf;
+}
+
+static const char *decode_flags(unsigned char flags)
+{
+	static char buf[128];
+
+	sprintf(buf, "0x%x (%s%s%s)", flags,
+		flags & LCK_PARTIAL_MODE	  ? "PARTIAL " : "",
+		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC " : "",
+		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR " : "");
+
+	return buf;
+}
+
 char *get_last_lvm_error()
 {
 	return last_error;
@@ -312,8 +401,8 @@
 {
 	int status = 0;
 
-	DEBUGLOG("do_lock_lv: resource '%s', cmd = 0x%x, flags = %x\n",
-		 resource, command, lock_flags);
+	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s\n",
+		 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
 	pthread_mutex_lock(&lvm_lock);
 	if (!cmd->config_valid || config_files_changed(cmd)) {
@@ -391,8 +480,8 @@
 	   before suspending cluster-wide.
 	 */
 	if (command == LCK_LV_SUSPEND) {
-		DEBUGLOG("pre_lock_lv: resource '%s', cmd = 0x%x, flags = %d\n",
-			 resource, command, lock_flags);
+		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
+			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
 		if (hold_lock(resource, LKM_PWMODE, LKF_NOQUEUE))
 			return errno;
@@ -411,8 +500,8 @@
 		int oldmode;
 
 		DEBUGLOG
-		    ("post_lock_lv: resource '%s', cmd = 0x%x, flags = %d\n",
-		     resource, command, lock_flags);
+		    ("post_lock_lv: resource '%s', cmd = %s, flags = %s\n",
+		     resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
 		/* If the lock state is PW then restore it to what it was */
 		oldmode = get_current_lock(resource);
@@ -505,6 +594,7 @@
  */
 void drop_metadata(const char *vgname)
 {
+	DEBUGLOG("Dropping metadata for VG %s\n", vgname);
 	pthread_mutex_lock(&lvm_lock);
 	lvmcache_drop_metadata(vgname);
 	pthread_mutex_unlock(&lvm_lock);
--- LVM2/daemons/clvmd/clvmd.c	2008/05/09 09:59:39	1.46
+++ LVM2/daemons/clvmd/clvmd.c	2008/06/05 14:24:28	1.47
@@ -191,6 +191,58 @@
 	}
 }
 
+static const char *decode_cmd(unsigned char cmdl)
+{
+	static char buf[128];
+	const char *command;
+
+	switch (cmdl) {
+	case CLVMD_CMD_TEST:		
+		command = "TEST";	
+		break;
+	case CLVMD_CMD_LOCK_VG:		
+		command = "LOCK_VG";	
+		break;
+	case CLVMD_CMD_LOCK_LV:		
+		command = "LOCK_LV";	
+		break;
+	case CLVMD_CMD_REFRESH:		
+		command = "REFRESH";	
+		break;
+	case CLVMD_CMD_SET_DEBUG:	
+		command = "SET_DEBUG";	
+		break;
+	case CLVMD_CMD_GET_CLUSTERNAME:	
+		command = "GET_CLUSTERNAME";
+		break;
+	case CLVMD_CMD_VG_BACKUP:	
+		command = "VG_BACKUP";	
+		break;
+	case CLVMD_CMD_REPLY:		
+		command = "REPLY";	
+		break;
+	case CLVMD_CMD_VERSION:		
+		command = "VERSION";	
+		break;
+	case CLVMD_CMD_GOAWAY:		
+		command = "GOAWAY";	
+		break;
+	case CLVMD_CMD_LOCK:		
+		command = "LOCK";	
+		break;
+	case CLVMD_CMD_UNLOCK:		
+		command = "UNLOCK";	
+		break;
+	default:			
+		command = "unknown";    
+		break;
+	}
+
+	sprintf(buf, "%s (0x%x)", command, cmdl);
+
+	return buf;
+}
+
 int main(int argc, char *argv[])
 {
 	int local_sock;
@@ -1169,8 +1221,8 @@
 	/* Get the node name as we /may/ need it later */
 	clops->name_from_csid(csid, nodename);
 
-	DEBUGLOG("process_remote_command %d for clientid 0x%x XID %d on node %s\n",
-		 msg->cmd, msg->clientid, msg->xid, nodename);
+	DEBUGLOG("process_remote_command %s for clientid 0x%x XID %d on node %s\n",
+		 decode_cmd(msg->cmd), msg->clientid, msg->xid, nodename);
 
 	/* Check for GOAWAY and sulk */
 	if (msg->cmd == CLVMD_CMD_GOAWAY) {
@@ -1441,8 +1493,9 @@
 	int replylen = 0;
 	int status;
 
-	DEBUGLOG("process_local_command: msg=%p, msglen =%d, client=%p\n", msg,
-		 msglen, client);
+	DEBUGLOG("process_local_command: %s msg=%p, msglen =%d, client=%p\n",
+		 decode_cmd(msg->cmd), msg, msglen, client);
+
 	if (replybuf == NULL)
 		return -1;
 


