From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 28 Aug 2009 05:27:09 -0000
Subject: LVM2/daemons/clogd functions.c
Message-ID: <20090828052709.12553.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-08-28 05:27:09

Modified files:
	daemons/clogd  : functions.c 

Log message:
	cluster log daemon (clogd): Adjust for kernel CTR arg reordering
	
	We have moved the internally generated mirror-device-size
	parameter from the end of the CTR string to the begining.
	This change adjusts for that.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/daemons/clogd/functions.c	2009/08/13 16:34:07	1.8
+++ LVM2/daemons/clogd/functions.c	2009/08/28 05:27:09	1.9
@@ -540,6 +540,7 @@
 {
 	int argc, i, r = 0;
 	char *p, **argv = NULL;
+	char *dev_size_str;
 	uint64_t device_size;
 
 	/* Sanity checks */
@@ -559,14 +560,16 @@
 	}
 
 	/* Split up args */
-	for (argc = 1, p = rq->data; (p = strstr(p, " ")); p++, argc++)
+	for (argc = 0, p = rq->data; (p = strstr(p, " ")); p++, argc++)
 		*p = '\0';
 
 	argv = malloc(argc * sizeof(char *));
 	if (!argv)
 		return -ENOMEM;
 
-	for (i = 0, p = rq->data; i < argc; i++, p = p + strlen(p) + 1)
+	p = dev_size_str = rq->data;
+	p += strlen(p) + 1;
+	for (i = 0; i < argc; i++, p = p + strlen(p) + 1)
 		argv[i] = p;
 
 	if (strcmp(argv[0], "clustered_disk") &&
@@ -576,13 +579,12 @@
 		return -EINVAL;
 	}
 
-	if (!(device_size = strtoll(argv[argc - 1], &p, 0)) || *p) {
-		LOG_ERROR("Invalid device size argument: %s", argv[argc - 1]);
+	if (!(device_size = strtoll(dev_size_str, &p, 0)) || *p) {
+		LOG_ERROR("Invalid device size argument: %s", dev_size_str);
 		free(argv);
 		return -EINVAL;
 	}
 
-	argc--;  /* We pass in the device_size separate */
 	r = _clog_ctr(rq->uuid, rq->luid, argc - 1, argv + 1, device_size);
 
 	/* We join the CPG when we resume */


