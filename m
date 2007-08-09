From: jorge alberto garcia gonzalez <jorge.garciag@mail.telcel.com>
Date: Thu, 09 Aug 2007 15:44:12 -0500
Subject: vgremove -f option add
Message-ID: <0JMI00FL0XLWQOB0@mta.telcel.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Yesterday I send this mail, but nobody has answer me: 

 

 

hello,  i write a little patch to add a force (or recursive ?) option to
vgremove 
i think  the semantic is better if you call vgremove -f <vg>  than 
call lvremove <vg> and then vgremove <vg> 

Example:



(list lv's)
root at cobalto:/usr/local/src/LVM2/tools# lvm lvs
  LV        VG     Attr   LSize   Origin Snap%  Move Log Copy% 
  lvprueba1 prueba -wi-a- 128.00M                              
  lvprueba2 prueba -wi-a- 128.00M                              
  lvprueba3 prueba -wi-a- 128.00M                              
  lvprueba4 prueba -wi-a- 128.00M                              



(delete vg prueba: here is the point )
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

 



Este mensaje es exclusivamente para el uso de la persona o entidad a quien esta dirigido; contiene informacion estrictamente confidencial y legalmente protegida, cuya divulgacion es sancionada por la ley. Si el lector de este mensaje no es a quien esta dirigido, ni se trata del empleado o agente responsable de esta informacion, se le notifica por medio del presente, que su reproduccion y distribucion, esta estrictamente prohibida. Si Usted recibio este comunicado por error, favor de notificarlo inmediatamente al remitente y destruir el mensaje. Todas las opiniones contenidas en este mail son propias del autor del mensaje y no necesariamente coinciden con las de Radiomovil Dipsa, S.A. de C.V. o alguna de sus empresas controladas, controladoras, afiliadas y subsidiarias. Este mensaje intencionalmente no contiene acentos.

This message is for the sole use of the person or entity to whom it is being sent.  Therefore, it contains strictly confidential and legally protected material whose disclosure is subject to penalty by law.  If the person reading this message is not the one to whom it is being sent and/or is not an employee or the responsible agent for this information, this person is herein notified that any unauthorized dissemination, distribution or copying of the materials included in this facsimile is strictly prohibited.  If you received this document by mistake please notify  immediately to the subscriber and destroy the message. Any opinions contained in this e-mail are those of the author of the message and do not necessarily coincide with those of Radiomovil Dipsa, S.A. de C.V. or any of its control, controlled, affiliates and subsidiaries companies. No part of this message or attachments may be used or reproduced in any manner whatsoever.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/78069254/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgremove-force_option.diff
Type: application/octet-stream
Size: 11367 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/78069254/attachment.obj>
