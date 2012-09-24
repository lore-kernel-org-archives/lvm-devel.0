From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:12 -0500
Subject: [PATCH 01/12] test.py Reformated to use spaces
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test.py | 121 ++++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 60 insertions(+), 61 deletions(-)

diff --git a/test.py b/test.py
index 3fb629a..7a2b078 100644
--- a/test.py
+++ b/test.py
@@ -9,96 +9,95 @@ import lvm
 
 #Dump information about PV
 def print_pv(pv):
-	print 'PV name: ', pv.getName(), ' ID: ' , pv.getUuid()	, 'Size: ' , pv.getSize()
+    print 'PV name: ', pv.getName(), ' ID: ', pv.getUuid(), 'Size: ', pv.getSize()
 
 
 #Dump some information about a specific volume group
 def print_vg(h, vg_name):
+    #Open read only
+    vg = h.vgOpen(vg_name, 'r')
 
-	#Open read only
-	vg = h.vgOpen(vg_name, 'r')
+    print 'Volume group:', vg_name, 'Size: ', vg.getSize()
 
-	print 'Volume group:', vg_name, 'Size: ', vg.getSize()
+    #Retrieve a list of Physical volumes for this volume group
+    pv_list = vg.listPVs()
 
-	#Retrieve a list of Physical volumes for this volume group
-	pv_list = vg.listPVs()
+    #Print out the physical volumes
+    for p in pv_list:
+        print_pv(p)
 
-	#Print out the physical volumes
-	for p in pv_list:
-		print_pv(p)
+    #Get a list of logical volumes in this volume group
+    lv_list = vg.listLVs()
+    if len(lv_list):
+        for l in lv_list:
+            print 'LV name: ', l.getName(), ' ID: ', l.getUuid()
+    else:
+        print 'No logical volumes present!'
 
-	#Get a list of logical volumes in this volume group
-	lv_list = vg.listLVs()
-	if len(lv_list):
-		for l in lv_list:
-			print 'LV name: ', l.getName(), ' ID: ', l.getUuid()
-	else:
-		print 'No logical volumes present!'
-
-	vg.close()
+    vg.close()
 
 #Returns the name of a vg with space available
 def find_vg_with_free_space(h):
-	free_space = 0
-	rc = None
+    free_space = 0
+    rc = None
 
-	vg_names = l.listVgNames()
-	for v in vg_names:
-		vg = h.vgOpen(v, 'r')
-		c_free = vg.getFreeSize()
-		if c_free > free_space:
-			free_space = c_free
-			rc = v
-		vg.close()
+    vg_names = l.listVgNames()
+    for v in vg_names:
+        vg = h.vgOpen(v, 'r')
+        c_free = vg.getFreeSize()
+        if c_free > free_space:
+            free_space = c_free
+            rc = v
+        vg.close()
 
-	return rc
+    return rc
 
 #Walk through the volume groups and fine one with space in which we can
 #create a new logical volume
 def create_delete_logical_volume(h):
-	vg_name = find_vg_with_free_space(h)
+    vg_name = find_vg_with_free_space(h)
 
-	print 'Using volume group ', vg_name , ' for example'
+    print 'Using volume group ', vg_name, ' for example'
 
-	if vg_name:
-		vg = h.vgOpen(vg_name, 'w')
-		lv = vg.createLvLinear('python_lvm_ok_to_delete', vg.getFreeSize())
+    if vg_name:
+        vg = h.vgOpen(vg_name, 'w')
+        lv = vg.createLvLinear('python_lvm_ok_to_delete', vg.getFreeSize())
 
-		if lv:
-			print 'New lv, id= ' , lv.getUuid()
+        if lv:
+            print 'New lv, id= ', lv.getUuid()
 
-			#Create a tag
-			lv.addTag('Demo_tag')
+            #Create a tag
+            lv.addTag('Demo_tag')
 
-			#Get the tags
-			tags = lv.getTags()
-			for t in tags:
-				#Remove tag
-				lv.removeTag(t)
+            #Get the tags
+            tags = lv.getTags()
+            for t in tags:
+                #Remove tag
+                lv.removeTag(t)
 
-			lv.deactivate()
-			lv.remove()
+            lv.deactivate()
+            lv.remove()
 
-		vg.close()
-	else:
-		print 'No free space available to create demo lv!'
+        vg.close()
+    else:
+        print 'No free space available to create demo lv!'
 
 if __name__ == '__main__':
-	#Create a new LVM instance
-	l = lvm.Liblvm()
+    #Create a new LVM instance
+    l = lvm.Liblvm()
 
-	#What version
-	print 'lvm version=', l.getVersion()
+    #What version
+    print 'lvm version=', l.getVersion()
 
-	#Get a list of volume group names
-	vg_names = l.listVgNames()
+    #Get a list of volume group names
+    vg_names = l.listVgNames()
 
-	#For each volume group display some information about each of them
-	for vg_i in vg_names:
-		print_vg(l, vg_i)
+    #For each volume group display some information about each of them
+    for vg_i in vg_names:
+        print_vg(l, vg_i)
 
-	#Demo creating a logical volume
-	create_delete_logical_volume(l)
+    #Demo creating a logical volume
+    create_delete_logical_volume(l)
 
-	#Close
-	l.close()
+    #Close
+    l.close()
-- 
1.7.11.4


