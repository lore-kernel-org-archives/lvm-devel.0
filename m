From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 25 Jul 2007 15:57:23 -0400
Subject: new device-mapper required to build latest lvm from cvs
In-Reply-To: <87wswplmgl.fsf@rho.meyering.net>
References: <87wswplmgl.fsf@rho.meyering.net>
Message-ID: <46A7AB23.7050306@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Jim Meyering wrote:
> FYI, with the change I've just committed,
> 
>   http://sources.redhat.com/ml/lvm2-cvs/2007-07/msg00035.html
> 
> you now need a device-mapper library and headers built from
> today's cvs sources.  Otherwise, you'll get compile warnings
> and eventually a link error complaining about missing dm_fclose.

This change introduces an error for static build.

/usr/local/lib/libdevmapper.a(libdm-file.o): In function `create_dir':
/work/device-mapper/lib/libdm-file.c:59: multiple definition of `create_dir'
../lib/liblvm.a(lvm-file.o):/work/LVM2/lib/misc/lvm-file.c:177: first defined here
/usr/bin/ld: Warning: size of symbol `create_dir' changed from 176 in ../lib/liblvm.a(lvm-file.o) to 187 in /usr/local/lib/libdevmapper.a(libdm-file.o)

lvm_fclose() calls dm_fclose(), which cause the linker to
bring libdm-file.o in liblvm.a. Then there happens a conflict
of create_dir().

Attached is a patch for device-mapper to rename the function
and export it. It alone fixes the build error.

A patch for LVM2 to use the exported function will follow.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: dm-dm_create_dir.patch
Type: text/x-patch
Size: 2195 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070725/eaaba228/attachment.bin>
