From: Chiyohiko Morita <morita@valinux.co.jp>
Date: Thu, 13 Feb 2014 11:58:06 +0900
Subject: VG archive files won't be removed after a long run.
In-Reply-To: <20140210203429.752A.DDAE3F33@valinux.co.jp>
References: <20140210203429.752A.DDAE3F33@valinux.co.jp>
Message-ID: <20140213115805.3B08.DDAE3F33@valinux.co.jp>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> 
> (I'm not on this list; please Cc me)
> 
> When the VG archive file is created more than 100,000 times, 
> if there don't exist files with indices from "00000" to "10000",
> the file name always because vg_name_100000-random_numbers.vg.
> The index number part of the names is always "100000".
> 
> I think that there is a problem with the _insert_archive_file() function.
> The last line of the _insert_archive_file() function is to add a table 
> at the head of the archives list. (See line indicated by (*))
> I think in this case, and you should add the table at the tail of the list.
> 
> The related source code is shown below.
> 
> ==============================================================================
> lvm2-2_02_104/lib/format_text/archive.c
I'm sorry. 
The version was wrong. The right version is LVM2.2.02.87.
(The _insert_archive_file() source code of lvm2-2.02.87-6.el6.x86_64 
 is the same as lvm2-2_02_104.)
> ------------------------------------------------------------------------------
> static void _insert_archive_file(struct dm_list *head, struct archive_file *b)
> {
>         struct archive_file *bf = NULL;
> 
>         if (dm_list_empty(head)) {
>                 dm_list_add(head, &b->list);
>                 return;
>         }
> 
>         /* index reduces through list */
>         dm_list_iterate_items(bf, head) {
>                 if (b->index > bf->index) {
>                         dm_list_add(&bf->list, &b->list);
>                         return;
>                 }
>         }
> 
>         dm_list_add_h(&bf->list, &b->list);	(*)
> }
> 
I use LVM of version lvm2-2.02.87-6.el6.x86_64.
Please refer to the following for package information and 'vgs, lvs -a, pvs' command output. 

# rpm -qa | grep kernel-2
kernel-2.6.32-220.23.1.el6.x86_64
kernel-2.6.32-220.el6.x86_64
(RHEL/CentOS 6.2)

# rpm -qa | grep lvm2
lvm2-libs-2.02.87-6.el6.x86_64
lvm2-2.02.87-6.el6.x86_64
lvm2-debuginfo-2.02.87-6.el6.x86_64

# vgs
  VG      #PV #LV #SN Attr   VSize VFree
  test-vg   2   5   2 wz--n- 7.99g 4.98g

# lvs -a
  LV          VG      Attr   LSize Origin Snap%  Move Log Copy%  Convert
  data01      test-vg owi-a- 1.00g
  data01_snap test-vg swi-a- 4.00m data01   0.00
  data02      test-vg owi-a- 1.00g
  data02_snap test-vg swi-a- 4.00m data02   0.00
  data03      test-vg -wi-a- 1.00g

# pvs
  PV         VG      Fmt  Attr PSize PFree
  /dev/vdb1  test-vg lvm2 a--  4.00g 1012.00m
  /dev/vdb2  test-vg lvm2 a--  4.00g    4.00g

# diff -upN /etc/lvm/lvm.conf.org /etc/lvm/lvm.conf
--- lvm.conf.org        2011-12-08 07:48:23.000000000 +0900
+++ /etc/lvm/lvm.conf   2014-02-12 07:35:34.000000000 +0900
@@ -63,7 +63,7 @@ devices {


     # By default we accept every block device:
-    filter = [ "a/.*/" ]
+    filter = [ "a|/dev/vdb*|", "r|.*|" ]

     # Exclude the cdrom drive
     # filter = [ "r|/dev/cdrom|" ]
- - - - - - - - - - - - - - - - - - - - - - - - - - 

# cat /etc/lvm/lvm.conf
	:
    # What is the minimum time you wish to keep an archive file for ?
    retain_days = 30
	:
- - - - - - - - - - - - - - - - - - - - - - - - - - 

I'm sorry.
Since there was a Japanese notation, I corrected. 

> Additional info:
> 
> <example: File index number 00000-10000 does not exist.>
[/etc/lvm/archive]# ls -al 
total 406320
drwxr-xr-x. 2 root root 6402048 Feb 10 07:54 .
drwxr-xr-x. 7 root root    4096 Feb 10 07:53 ..
-rw-------. 1 root root    2378 Jan 31 18:24 test-vg_100000-1204670439.vg	(**)
-rw-------. 1 root root    1773 Jan 31 18:10 test-vg_100000-1241353072.vg	(**)
-rw-------. 1 root root    2378 Jan 31 17:59 test-vg_100000-1369206884.vg	(**)
-rw-------. 1 root root    2378 Jan 31 18:21 test-vg_100000-1740312384.vg	(**)
-rw-------. 1 root root    1773 Jan 31 18:31 test-vg_100000-1798506701.vg	(**)
-rw-------. 1 root root    2378 Jan 31 17:50 test-vg_100000-2045350629.vg	(**)
-rw-------. 1 root root    2086 Jan 29 15:09 test-vg_10001-444418726.vg
-rw-------. 1 root root    2705 Jan 29 15:09 test-vg_10002-991152144.vg
-rw-------. 1 root root    3322 Jan 29 15:09 test-vg_10003-1382812875.vg
-rw-------. 1 root root    3925 Jan 29 15:09 test-vg_10004-1229258138.vg
	:
-rw-------. 1 root root    3322 Jan 31 02:14 test-vg_99997-1786673524.vg
-rw-------. 1 root root    3925 Jan 31 02:14 test-vg_99998-1284671590.vg
-rw-------. 1 root root    3306 Jan 31 02:14 test-vg_99999-1949909947.vg

(**):Index numbers are the same.

Even if it becomes on February 30, files created on January 29 won't deleted. 
Because, there exist test-vg_100000-<random_numbers>.vg files in /etc/lvm/archive. 


> <example: File index number 00000-10000 exist.>
[/etc/lvm/archive]# ls -al
total 366668
drwxr-xr-x. 2 root root 6402048 Feb 10 11:55 .
drwxr-xr-x. 7 root root    4096 Feb 10 11:43 ..
-rw-------. 1 root root    1109 Jan 29 11:59 test-vg_00000-2082297108.vg
-rw-------. 1 root root    1442 Jan 29 12:00 test-vg_00001-190015709.vg
-rw-------. 1 root root    1771 Jan 29 12:01 test-vg_00002-1842787566.vg
	 :
-rw-------. 1 root root    3925 Jan 29 15:09 test-vg_09998-916990031.vg
-rw-------. 1 root root    3306 Jan 29 15:09 test-vg_09999-800050091.vg
-rw-------. 1 root root    2685 Jan 29 15:09 test-vg_10000-746926820.vg
-rw-------. 1 root root    2685 Jan 31 02:14 test-vg_100000-528314802.vg
-rw-------. 1 root root    2086 Jan 31 02:14 test-vg_100001-1539419450.vg
	:
-rw-------. 1 root root    3322 Jan 31 02:15 test-vg_100009-168721966.vg
-rw-------. 1 root root    2086 Jan 29 15:09 test-vg_10001-444418726.vg
-rw-------. 1 root root    3925 Jan 31 02:15 test-vg_100010-1968226420.vg
-rw-------. 1 root root    2086 Jan 31 02:14 test-vg_100001-1539419450.vg
	:
-rw-------. 1 root root    2086 Jan 31 02:15 test-vg_100019-589867197.vg
-rw-------. 1 root root    2705 Jan 29 15:09 test-vg_10002-991152144.vg
-rw-------. 1 root root    2705 Jan 31 02:15 test-vg_100020-300714866.vg
-rw-------. 1 root root    3322 Jan 31 02:15 test-vg_100021-333183948.vg
	:
-rw-------. 1 root root    3306 Jan 31 02:15 test-vg_100029-249595924.vg
-rw-------. 1 root root    3322 Jan 29 15:09 test-vg_10003-1382812875.vg
-rw-------. 1 root root    2685 Jan 31 02:15 test-vg_100030-1220134385.vg
-rw-------. 1 root root    2086 Jan 31 02:15 test-vg_100031-981943972.vg
	:
-rw-------. 1 root root    3322 Jan 31 02:16 test-vg_100039-1249509839.vg
-rw-------. 1 root root    3925 Jan 29 15:09 test-vg_10004-1229258138.vg
-rw-------. 1 root root    3925 Jan 31 02:16 test-vg_100040-1288607163.vg
	:
-rw-------. 1 root root    2086 Jan 31 02:17 test-vg_100097-450415415.vg
-rw-------. 1 root root    2705 Jan 31 02:17 test-vg_100098-1044414870.vg
-rw-------. 1 root root    3322 Jan 31 02:17 test-vg_100099-1167588496.vg
-rw-------. 1 root root    3925 Jan 29 15:09 test-vg_10010-128770730.vg
-rw-------. 1 root root    3306 Jan 29 15:09 test-vg_10011-1575005460.vg
-rw-------. 1 root root    2685 Jan 29 15:09 test-vg_10012-1276134968.vg
-rw-------. 1 root root    2086 Jan 29 15:09 test-vg_10013-2102715722.vg
-rw-------. 1 root root    2705 Jan 29 15:09 test-vg_10014-2041113299.vg
-rw-------. 1 root root    3322 Jan 29 15:09 test-vg_10015-1772090647.vg
	:
-rw-------. 1 root root    3322 Jan 31 02:14 test-vg_99997-1786673524.vg
-rw-------. 1 root root    3925 Jan 31 02:14 test-vg_99998-1284671590.vg
-rw-------. 1 root root    3306 Jan 31 02:14 test-vg_99999-1949909947.vg

> - - - - - - - - - - - - - - - - - - - -
> 

Thanks,

--
Chiyohiko Morita <morita valinux co jp>


