From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Jun 2010 08:54:33 -0000
Subject: LVM2 ./WHATS_NEW libdm/libdm-deptree.c
Message-ID: <20100621085433.1811.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-06-21 08:54:32

Modified files:
	.              : WHATS_NEW 
	libdm          : libdm-deptree.c 

Log message:
	Use early udev synchronisation and update of dev nodes for clustered mirrors.
	
	When using clustered mirrors, we need device nodes to be created during
	processing of device tree, not at its end like we normally do (we need to
	access the nodes in cmirror prematurely). Therefore we use a new flag called
	"immediate_dev_node" stored in deptree's load_properties struct to instruct the
	device tree processing code to immediately synchronize with udev and flush all
	stacked node operations so the nodes are prepared for use.
	
	For now, the immediate_dev_node is used for clustered mirrors during
	processing the dm_tree_preload_children code only. We can add more later if
	needed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1619&r2=1.1620
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/WHATS_NEW	2010/06/18 20:58:04	1.1619
+++ LVM2/WHATS_NEW	2010/06/21 08:54:32	1.1620
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Use early udev synchronisation and update of dev nodes for clustered mirrors.
   Unneeded kdev_t.h reference causing harm for cmirrord on some archs.
   Add man pages for lvmconf and unsupported lvmsadc and lvmsar tools.
   Fix exit code when requesting help using documented -o help option.
--- LVM2/libdm/libdm-deptree.c	2010/05/25 08:40:36	1.82
+++ LVM2/libdm/libdm-deptree.c	2010/06/21 08:54:32	1.83
@@ -143,6 +143,13 @@
 	struct dm_list segs;
 
 	const char *new_name;
+
+	/* If immediate_dev_node is set to 1, try to create the dev node
+	 * as soon as possible (e.g. in preload stage even during traversal
+	 * and processing of dm tree). This will also flush all stacked dev
+	 * node operations, synchronizing with udev.
+	 */
+	int immediate_dev_node;
 };
 
 /* Two of these used to join two nodes with uses and used_by. */
@@ -1843,6 +1850,7 @@
 	void *handle = NULL;
 	struct dm_tree_node *child;
 	struct dm_info newinfo;
+	int update_devs_flag = 0;
 
 	/* Preload children first */
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
@@ -1897,10 +1905,26 @@
 
 		/* Update cached info */
 		child->info = newinfo;
+
+		/*
+		 * Prepare for immediate synchronization with udev and flush all stacked
+		 * dev node operations if requested by immediate_dev_node property. But
+		 * finish processing current level in the tree first.
+		 */
+		if (child->props.immediate_dev_node)
+			update_devs_flag = 1;
+
 	}
 
 	handle = NULL;
 
+	if (update_devs_flag) {
+		if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
+			stack;
+		dm_tree_set_cookie(dnode, 0);
+		dm_task_update_nodes();
+	}
+
 	return r;
 }
 
@@ -2157,6 +2181,9 @@
 				return 0;
 			}
 
+			if (clustered)
+				log_node->props.immediate_dev_node = 1;
+
 			if (!_link_tree_nodes(node, log_node))
 				return_0;
 		}


