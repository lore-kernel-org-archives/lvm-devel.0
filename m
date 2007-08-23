From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 23 Aug 2007 16:56:05 -0400
Subject: vgremove -f option add
In-Reply-To: <0JMI00FL0XLWQOB0@mta.telcel.com>
References: <0JMI00FL0XLWQOB0@mta.telcel.com>
Message-ID: <1187902565.4547.15.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2007-08-09 at 15:44 -0500, jorge alberto garcia gonzalez wrote:
> Yesterday I send this mail, but nobody has answer me: 
> 
>  
> 
>  
> 
> hello,  i write a little patch to add a force (or recursive ?) option
> to vgremove 
> i think  the semantic is better if you call vgremove -f <vg>  than 
> call lvremove <vg> and then vgremove <vg> 
> 
> Example:
> 
> 
> 
> (list lv?s)
> root at cobalto:/usr/local/src/LVM2/tools# lvm lvs
>   LV        VG     Attr   LSize   Origin Snap%  Move Log Copy% 
>   lvprueba1 prueba -wi-a- 128.00M                             
>   lvprueba2 prueba -wi-a- 128.00M                             
>   lvprueba3 prueba -wi-a- 128.00M                             
>   lvprueba4 prueba -wi-a- 128.00M                             
> 
> 
> 
> (delete vg prueba: here is the point )
> root at cobalto:/usr/local/src/LVM2/tools# ./lvm vgremove -f prueba 
>   Logical volume "lvprueba1" successfully removed
>   Logical volume "lvprueba2" successfully removed
>   Logical volume "lvprueba3" successfully removed
>   Logical volume "lvprueba4" successfully removed 
>   Volume group "prueba" successfully removed
> 
> 
> root at cobalto:/usr/local/src/LVM2/tools# ./lvm lvs 
> root at cobalto:/usr/local/src/LVM2/tools# 
> root at cobalto:/usr/local/src/LVM2/tools# ./lvm vgdisplay prueba 
>   Volume group "prueba" not found
> 
> 
> Sorry i dont know the procedure to submit a patch, this is my firt
> time ever a send a patch to any gnu project. 
> 

Thanks for the submission - you did fine.  In the future, just try to be
a little more mindful of the existing coding style.  Also try to avoid
additions of whitespaces, debug code, etc.

I did some cleanup work first and I've attached an updated patch against
the latest code.  Patch was tested against a simple cluster as well as
single node and seems to work fine.  Some sample output in a clustered
environment:

# lvs
  LV       VG         Attr   LSize  Origin Snap%  Move Log Copy% 
  LogVol00 VolGroup00 -wi-ao  5.84G                              
  LogVol01 VolGroup00 -wi-ao  1.03G                              
  lv0      vg0        -wi-a- 96.00M                              
# vgs
  VG         #PV #LV #SN Attr   VSize   VFree  
  VolGroup00   1   2   0 wz--n-   6.91G  32.00M
  vg0          5   1   0 wz--nc 240.00M 144.00M
# vgremove vg0
Do you really want to remove volume group "vg0" with active logical volumes? [y/n]: n
  Volume group "vg0" not removed
# vgremove -f vg0
  Error locking on node rhel4u5-node1: Volume is busy on another node
  Can't get exclusive access to volume "lv0"
# vgremove vg0
Do you really want to remove volume group "vg0" with active logical volumes? [y/n]: y
Do you really want to remove active logical volume "lv0"? [y/n]: y
  Error locking on node rhel4u5-node1: Volume is busy on another node
  Can't get exclusive access to volume "lv0"
# lvchange -an vg0/lv0
# vgremove vg0
Do you really want to remove volume group "vg0" with active logical volumes? [y/n]: y
  Logical volume "lv0" successfully removed
  Volume group "vg0" successfully removed




> Thanks!
> 
> Saludos
> -------------------------------------- 
> Index: commands.h
> ===================================================================
> RCS file: /cvs/lvm2/LVM2/tools/commands.h,v
> retrieving revision 1.98
> diff -u -r1.98 commands.h
> --- commands.h  1 Aug 2007 21:01:06 -0000       1.98
> +++ commands.h  9 Aug 2007 02:28:01 -0000
> @@ -806,6 +806,7 @@
>  xx(vgremove,
>     "Remove volume group(s)",
>     "vgremove\n"
> +   "\t[-f|--force]\n"
>     "\t[-d|--debug]\n" 
>     "\t[-h|--help]\n"
>     "\t[-t|--test]\n"
> @@ -813,7 +814,7 @@
>     "\t[--version]" "\n"
>     "\tVolumeGroupName [VolumeGroupName...]\n",
>  
> -   test_ARG) 
> +   force_ARG,test_ARG)
>  
>  xx(vgrename,
>     "Rename a volume group",
> @@ -827,7 +828,7 @@
>     "\tOldVolumeGroupPath NewVolumeGroupPath |\n"
>     "\tOldVolumeGroupName NewVolumeGroupName\n", 
>  
> -   autobackup_ARG, force_ARG, test_ARG)
> +   autobackup_ARG, test_ARG)
>  
>  xx(vgs,
>     "Display information about volume groups",
> Index: lvm.c
> 
> Index: vgremove.c
> =================================================================== 
> RCS file: /cvs/lvm2/LVM2/tools/vgremove.c,v
> retrieving revision 1.41
> diff -u -r1.41 vgremove.c
> --- vgremove.c  19 Jun 2007 04:36:12 -0000      1.41
> +++ vgremove.c  9 Aug 2007 02:28:04 -0000
> @@ -34,9 +34,13 @@ 
>         if (!vg_check_status(vg, EXPORTED_VG))
>                 return ECMD_FAILED;
>  
> +       /* 
> +        * If there is 1 or more lv print a error
> +        * */
>         if (vg->lv_count) {
>                 log_error("Volume group \"%s\" still contains %d " 
>                           "logical volume(s)", vg_name, vg->lv_count);
> +
>                 return ECMD_FAILED;
>         }
>  
> @@ -84,21 +88,39 @@
>  int vgremove(struct cmd_context *cmd, int argc, char **argv) 
>  {
>         int ret;
> -
> +    
> +
>         if (!argc) {
>                 log_error("Please enter one or more volume group
> paths");
>                 return EINVALID_CMD_LINE;
>         }
> -
> +    //printf("argv= %s \n", argv[0]);
> +    
> +       //printf("hostname = %s \n" , cmd->cmd_line);
> +
> +
> +
> +
>         if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
>                 log_error("Can't get lock for orphan PVs"); 
>                 return ECMD_FAILED;
>         }
> -
> +/* check  -f argument  */
> +       if( arg_count(cmd,force_ARG ) ) {
> +               ret=lvremove(cmd,  argc, argv);
> +               if( ret==1 ){
> +               ret = process_each_vg(cmd, argc, argv, 
> +                                                 
> +                                                 LCK_VG_WRITE |
> LCK_NONBLOCK,1,
> +                                                 NULL, &
> vgremove_single); 
> +               }
> +
> +       }
> +       else{
>         ret = process_each_vg(cmd, argc, argv,
>                               LCK_VG_WRITE | LCK_NONBLOCK, 1, 
>                               NULL, &vgremove_single); 
> -
> +       }
>         unlock_vg(cmd, ORPHAN);
>  
>         return ret; 
> 
> 
> 
> -- 

> 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgremove-f-current.patch
Type: text/x-patch
Size: 3359 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070823/f9769665/attachment.bin>
