From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 11 Jan 2010 14:34:25 +0100
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
In-Reply-To: <20100108223236.28920.qmail@sourceware.org>
References: <20100108223236.28920.qmail@sourceware.org>
Message-ID: <4B4B28E1.2090903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Dne 8.1.2010 23:32, jbrassow at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	jbrassow at sourceware.org	2010-01-08 22:32:35
> 
> Modified files:
> 	.              : WHATS_NEW 
> 	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
> 	man            : lvconvert.8.in lvcreate.8.in 
> 	tools          : commands.h lvconvert.c lvcreate.c 
> 
> Log message:
> 	Add the new mirror log type "redundant".  The options are now:
> 	--mirrorlog core: in-memory log
> 	--mirrorlog disk: persistent log
> 	--mirrorlog redundant: redundant persistent log
> 	
> 	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>


> @@ -671,7 +671,7 @@
>  	if (existing_mirrors && lp->mirrors &&
>  	    (lp->mirrors != existing_mirrors) &&
>  	    !arg_count(cmd, mirrorlog_ARG) && !arg_count(cmd, corelog_ARG)) {
> -		corelog = first_seg(lv)->log_lv ? 0 : 1;
> +		log_count = lv_mirror_count(first_seg(lv)->log_lv);
>  	}


Hmm - this change has unpleasant result for our mirror testcase from test suit:

(gdb) bt
#0  0x080c23fe in lv_mirror_count (lv=0x0) at metadata/mirror.c:83
#1  0x0805b3f2 in _lvconvert_mirrors (cmd=0x9b5b028, lv=0x9b8e638,
lp=0xfff5bda0) at lvconvert.c:674
#2  0x0805cd9e in lvconvert_single (cmd=0x9b5b028, lv=0x9b8e638,
handle=0xfff5bda0) at lvconvert.c:1079
#3  0x0805d04b in lvconvert (cmd=0x9b5b028, argc=1, argv=0xfff5bf68) at
lvconvert.c:1130
#4  0x08064805 in lvm_run_command (cmd=0x9b5b028, argc=1, argv=0xfff5bf68) at
lvmcmdline.c:1030
#5  0x08065641 in lvm2_main (argc=5, argv=0xfff5bf58) at lvmcmdline.c:1373
#6  0x0807ed76 in main (argc=135335936, argv=0x55572670) at lvm.c:21


Obviously log_lv is 0 and lv_mirror_count fails.

Zdenek
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.13 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org/

iQIcBAEBAgAGBQJLSyjhAAoJEBiFrTh9QvFuXugP/isId9iUo0m1cjl1MmtIy973
8tKofM69IVm4/YoFlfaRTcFimv+LwTUA7noMroHwsaKA+d232eUKc1/SWFALop1c
/2OZzt53qaSjOBdfqSHpeNzXD4ce4yE6bkqcJ2pFIwAgzjNACwTC5R04Aw24Byll
/B/dwOWRy1cYHWsu/0pnFG8jL5MCdnXnlrh8AwrmoBCKFe6cMLkdwAsWSl0Q9N+d
em0q+z6OEbQYRjneLJMQ7WiEIt1Ow19K0LMVTIuO9g5ETPxjmX5yXhdLCT80RbTB
XKaLBAYTEpgNNT7CyTPkGxTAzMsNVjmU9bZBg6Jiclu6Bdy5KXY2wT1y6269rrhf
4pGxAz3fVWXXOKAtXPhKFxOmFk5+LzmZRx/QveISWKt7yuqbLTqSiHlxgAegwq6S
fjCvB1YEDYePncc3okmhX5CEf8n172R2BN+zywxWgRVo49nOrHJo22pag64cS+Wk
eKBbGO5c6b/V4zksxfgEDCXML/7UDNGZXXPA9GAq8Rom3kfIVwiLCMbV+7wMCvYY
2IArlaw5uMd2bkQnDjG8lgz5lw2k4hmfPTJDs45Q+sg61UcjVv9KUizlEHIpVhJc
njKxnCGhGE8Q3YXpMEUKAaOMnVupSXhsPpZQvNZ/XnrkBaPDLGqGA09aJFjZC/hh
5PzvHa7NUnUJsR7jKNVk
=Nbnq
-----END PGP SIGNATURE-----


