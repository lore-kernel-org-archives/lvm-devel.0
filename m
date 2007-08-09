From: jorge alberto garcia gonzalez <jorge.garcia.gonzalez@gmail.com>
Date: Thu, 9 Aug 2007 02:52:58 +0000
Subject: LVM2/lib/metadata lv_manip.c
In-Reply-To: <20070808180037.18571.qmail@sourceware.org>
References: <20070808180037.18571.qmail@sourceware.org>
Message-ID: <89a913ed0708081952x646b40d6x71a4bfc017abb80c@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

hello,  i write a little patch that add a force (or recursive ?) option to
vgremove
i think  the semantic is better if you call vgremove -f <vg>  than
call lvremove <vg> and then vgremove <vg>

Example:

root at cobalto:/usr/local/src/LVM2/tools# lvm lvs
  LV        VG     Attr   LSize   Origin Snap%  Move Log Copy%
  lvprueba1 prueba -wi-a- 128.00M
  lvprueba2 prueba -wi-a- 128.00M
  lvprueba3 prueba -wi-a- 128.00M
  lvprueba4 prueba -wi-a- 128.00M

root at cobalto:/usr/local/src/LVM2/tools# ./lvm vgremove -f prueba
  Logical volume "lvprueba1" successfully removed
  Logical volume "lvprueba2" successfully removed
  Logical volume "lvprueba3" successfully removed
  Logical volume "lvprueba4" successfully removed
  Volume group "prueba" successfully removed


root at cobalto:/usr/local/src/LVM2/tools# ./lvm lvs
root at cobalto:/usr/local/src/LVM2/tools#
root at cobalto:/usr/local/src/LVM2/tools# ./lvm vgdisplay prueba
  Volume group "prueba" not found


Sorry i dont know the procedure to submit a patch, this is my firt time ever
a send a patch to any gnu project.

Thanks!

Saludos
--------------------------------------
Index: commands.h
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/commands.h,v
retrieving revision 1.98
diff -u -r1.98 commands.h
--- commands.h  1 Aug 2007 21:01:06 -0000       1.98
+++ commands.h  9 Aug 2007 02:28:01 -0000
@@ -806,6 +806,7 @@
 xx(vgremove,
    "Remove volume group(s)",
    "vgremove\n"
+   "\t[-f|--force]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-t|--test]\n"
@@ -813,7 +814,7 @@
    "\t[--version]" "\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",

-   test_ARG)
+   force_ARG,test_ARG)

 xx(vgrename,
    "Rename a volume group",
@@ -827,7 +828,7 @@
    "\tOldVolumeGroupPath NewVolumeGroupPath |\n"
    "\tOldVolumeGroupName NewVolumeGroupName\n",

-   autobackup_ARG, force_ARG, test_ARG)
+   autobackup_ARG, test_ARG)

 xx(vgs,
    "Display information about volume groups",
Index: lvm.c

Index: vgremove.c
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/vgremove.c,v
retrieving revision 1.41
diff -u -r1.41 vgremove.c
--- vgremove.c  19 Jun 2007 04:36:12 -0000      1.41
+++ vgremove.c  9 Aug 2007 02:28:04 -0000
@@ -34,9 +34,13 @@
        if (!vg_check_status(vg, EXPORTED_VG))
                return ECMD_FAILED;

+       /*
+        * If there is 1 or more lv print a error
+        * */
        if (vg->lv_count) {
                log_error("Volume group \"%s\" still contains %d "
                          "logical volume(s)", vg_name, vg->lv_count);
+
                return ECMD_FAILED;
        }

@@ -84,21 +88,39 @@
 int vgremove(struct cmd_context *cmd, int argc, char **argv)
 {
        int ret;
-
+
+
        if (!argc) {
                log_error("Please enter one or more volume group paths");
                return EINVALID_CMD_LINE;
        }
-
+    //printf("argv= %s \n", argv[0]);
+
+       //printf("hostname = %s \n" , cmd->cmd_line);
+
+
+
+
        if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
                log_error("Can't get lock for orphan PVs");
                return ECMD_FAILED;
        }
-
+/* check  -f argument  */
+       if( arg_count(cmd,force_ARG ) ) {
+               ret=lvremove(cmd,  argc, argv);
+               if( ret==1 ){
+               ret = process_each_vg(cmd, argc, argv,
+
+                                                 LCK_VG_WRITE |
LCK_NONBLOCK,1,
+                                                 NULL, & vgremove_single);
+               }
+
+       }
+       else{
        ret = process_each_vg(cmd, argc, argv,
                              LCK_VG_WRITE | LCK_NONBLOCK, 1,
                              NULL, &vgremove_single);
-
+       }
        unlock_vg(cmd, ORPHAN);

        return ret;

-- 
No vivas solo por que respiras, vive para cumplir tus sue~os
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/6722d230/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgremove-force_option.diff
Type: text/x-patch
Size: 11367 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/6722d230/attachment.bin>
