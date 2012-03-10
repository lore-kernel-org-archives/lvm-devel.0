From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Mar 2012 09:32:48 -0000
Subject: LVM2/daemons clvmd/clvmd-openais.c cmirrord/cl ...
Message-ID: <20120310093248.2313.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-10 09:32:47

Modified files:
	daemons/clvmd  : clvmd-openais.c 
	daemons/cmirrord: cluster.c functions.c link_mon.c local.c 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 

Log message:
	Remove some whitespaces.
	(test commit)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/link_mon.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/local.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/daemons/clvmd/clvmd-openais.c	2011/09/25 19:37:00	1.18
+++ LVM2/daemons/clvmd/clvmd-openais.c	2012/03/10 09:32:46	1.19
@@ -506,7 +506,7 @@
 		saLckResourceClose(res_handle);
 		return ais_to_errno(err);
 	}
-			
+
 	/* Wait for it to complete */
 
 	DEBUGLOG("lock_resource returning %d, lock_id=%" PRIx64 "\n",
--- LVM2/daemons/cmirrord/cluster.c	2012/03/01 17:41:39	1.19
+++ LVM2/daemons/cmirrord/cluster.c	2012/03/10 09:32:47	1.20
@@ -89,7 +89,7 @@
 	char *clean_bits;
 	char *recovering_region;
 	struct checkpoint_data *next;
-};	
+};
 
 #define INVALID 0
 #define VALID   1
@@ -911,9 +911,9 @@
 
 			rq->u_rq.data_size = 0;
 			kernel_send(&rq->u_rq);
-				
+
 			break;
-			
+
 		default:
 			/*
 			 * If an action or a response is required, then
@@ -1355,7 +1355,7 @@
 		match->free_me = 1;
 		match->lowest_id = 0xDEAD;
 		match->state = INVALID;
-	}			
+	}
 
 	/* Remove any pending checkpoints for the leaving node. */
 	for (p_cp = NULL, c_cp = match->checkpoint_list;
@@ -1411,7 +1411,7 @@
 			 left->nodeid);
 		return;
 	}
-		
+
 	match->lowest_id = member_list[0].nodeid;
 	for (i = 0; i < member_list_entries; i++)
 		if (match->lowest_id > member_list[i].nodeid)
@@ -1530,7 +1530,7 @@
                 usleep(1000);
                 goto unlink_retry;
         }
-	
+
 	if (rv != SA_AIS_OK) {
                 LOG_ERROR("[%s] Failed to unlink checkpoint: %s",
                           SHORT_UUID(entry->name.value), str_ais_error(rv));
@@ -1633,7 +1633,7 @@
 {
 	int r;
 	int state;
-	
+
 	LOG_COND(log_resend_requests, "[%s] I am leaving.2.....",
 		 SHORT_UUID(del->name.value));
 
--- LVM2/daemons/cmirrord/functions.c	2012/02/08 11:36:18	1.32
+++ LVM2/daemons/cmirrord/functions.c	2012/03/10 09:32:47	1.33
@@ -784,7 +784,7 @@
 		else if (lc->disk_nr_regions > lc->region_count)
 			LOG_DBG("[%s] Mirror has shrunk, updating log bits",
 				SHORT_UUID(lc->uuid));
-		break;		
+		break;
 	case -EINVAL:
 		LOG_DBG("[%s] (Re)initializing mirror log - resync issued.",
 			SHORT_UUID(lc->uuid));
@@ -837,7 +837,7 @@
 	lc->sync_search = 0;
 	lc->state = LOG_RESUMED;
 	lc->recovery_halted = 0;
-	
+
 	return rq->error;
 }
 
@@ -1032,7 +1032,7 @@
 {
 	int r = 0;
 	struct log_c *lc = get_log(rq->uuid, rq->luid);
-	
+
 	if (!lc)
 		return -EINVAL;
 
@@ -1614,7 +1614,7 @@
 
 	rq->data_size = sizeof(*pkg);
 
-	return 0;	
+	return 0;
 }
 
 
--- LVM2/daemons/cmirrord/link_mon.c	2010/01/19 15:58:45	1.5
+++ LVM2/daemons/cmirrord/link_mon.c	2012/03/10 09:32:47	1.6
@@ -58,7 +58,7 @@
 			free(lc);
 			return -ENOMEM;
 		}
-		
+
 		pfds = tmp;
 		free_pfds = used_pfds + 1;
 	}
@@ -125,7 +125,7 @@
 	for (i = 0; i < used_pfds; i++)
 		if (pfds[i].revents & POLLIN) {
 			LOG_DBG("Data ready on %d", pfds[i].fd);
-				
+
 			/* FIXME: Add this back return 1;*/
 			r++;
 		}
--- LVM2/daemons/cmirrord/local.c	2010/07/09 15:34:41	1.9
+++ LVM2/daemons/cmirrord/local.c	2012/03/10 09:32:47	1.10
@@ -249,7 +249,7 @@
 		if (r)
 			LOG_ERROR("Failed to respond to kernel [%s]",
 				  RQ_TYPE(u_rq->request_type));
-			
+
 		break;
 	case DM_ULOG_RESUME:
 		/*
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2012/02/08 11:29:13	1.39
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2012/03/10 09:32:47	1.40
@@ -124,7 +124,7 @@
 out:
 	dm_free(args);
 	return r;
-	
+
 out_parse:
 	dm_free(args);
 	syslog(LOG_ERR, "Unable to parse mirror status string.");


