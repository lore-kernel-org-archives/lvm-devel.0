From: jorge alberto garcia gonzalez <jorge.garcia.gonzalez@gmail.com>
Date: Thu, 9 Aug 2007 02:46:05 +0000
Subject: LVM2/lib/metadata lv_manip.c
In-Reply-To: <20070808180037.18571.qmail@sourceware.org>
References: <20070808180037.18571.qmail@sourceware.org>
Message-ID: <89a913ed0708081946q787c12e2o571a861d6f1cb21b@mail.gmail.com>
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
root at cobalto:/usr/local/src/LVM2/tools# lvm vgremove -f prueba
vgremove: invalid option -- f
  Error during parsing of command line.
root at cobalto:/usr/local/src/LVM2/tools# ./lvm vgremove -f prueba
  Logical volume "lvprueba1" successfully removed
  Logical volume "lvprueba2" successfully removed
  Logical volume "lvprueba3" successfully removed
  Logical volume "lvprueba4" successfully removed
  Volume group "prueba" successfully removed
root at cobalto:/usr/local/src/LVM2/tools#





-- 
No vivas solo por que respiras, vive para cumplir tus sue~os
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/51c10b4a/attachment.htm>
