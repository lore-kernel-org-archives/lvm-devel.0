From: David Robinson <zxvdr.au@gmail.com>
Date: Wed, 22 Aug 2007 13:31:25 +1000
Subject: [PATCH] s-c-l crashes if LV mirror was created with --nosync
Message-ID: <46CBAE0D.60202@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

system-config-lvm crashes if there are mirrored logical volumes created
with --nosync (BZ 247325). lvs shows an attribute of 'M' for --nosync 
mirrors, not 'm'. The patch below corrects the problem.

--- lvm_model.py.orig   2007-07-12 00:10:29.000000000 +1000
+++ lvm_model.py        2007-07-12 00:11:14.000000000 +1000
@@ -496,7 +496,7 @@

        segment = None
        devs = devices.split(',')
-      if attrs[0] == 'm':
+      if attrs[0] == 'm' or attrs[0] == 'M':
          # mirrored LV
          lv.set_mirror_log(mirror_log) # tmp, will get replaced with 
real one at __link_mirrors()
          segment = MirroredSegment(seg_start, seg_size)


