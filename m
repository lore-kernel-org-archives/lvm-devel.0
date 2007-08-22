From: David Robinson <zxvdr.au@gmail.com>
Date: Wed, 22 Aug 2007 13:31:26 +1000
Subject: [PATCH] s-c-l crashes if LV mirror was created with --corelog
Message-ID: <46CBAE0E.2000405@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

system-config-lvm crashes if there are mirrored logical volumes created 
with --corelog (BZ 229234). The patch below corrects the problem.

--- lvm_model.py.orig	2007-07-12 00:10:29.000000000 +1000
+++ lvm_model.py	2007-07-15 16:19:50.000000000 +1000
@@ -572,9 +572,10 @@
            if lv.is_mirrored():
              # replace tmp lvs with real one
              # log
-            log_lv = vg.get_lvs()[lv.get_mirror_log()]
-            vg.get_lvs().pop(log_lv.get_name()) # remove log_lv from vg
-            lv.set_mirror_log(log_lv)
+            if lv.get_mirror_log():
+              log_lv = vg.get_lvs()[lv.get_mirror_log()]
+              vg.get_lvs().pop(log_lv.get_name()) # remove log_lv from vg
+              lv.set_mirror_log(log_lv)
              # images
              segment = lv.get_segments()[0]
              images_tmp = segment.get_images()[:] # copy
--- renderer.py.orig	2006-02-08 05:39:07.000000000 +1000
+++ renderer.py		2007-07-19 18:39:45.000000000 +1000
@@ -470,12 +470,13 @@
              # set up mirroring log
              if lv.is_mirrored():
                  log_lv = lv.get_mirror_log()
-                for seg2 in log_lv.get_segments():
-                    # log should have linear mapping only
-                    extent = seg2.get_extent_block()
-                    subcyl = Subcylinder(self.lv_cyl_gen, 1, 0, False, 
extent.get_start_size()[1])
-                    lv_cyls_dir[extent] = subcyl
-                    cyl.children.append(subcyl)
+                if log_lv:
+                   for seg2 in log_lv.get_segments():
+                       # log should have linear mapping only
+                       extent = seg2.get_extent_block()
+                       subcyl = Subcylinder(self.lv_cyl_gen, 1, 0, 
False, extent.get_start_size()[1])
+                       lv_cyls_dir[extent] = subcyl
+                       cyl.children.append(subcyl)

              # set up helper display
              cyl.add_object(CYL_ID_VOLUME, lv)


