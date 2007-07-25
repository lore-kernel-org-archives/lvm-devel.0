From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 25 Jul 2007 16:01:13 -0400
Subject: new device-mapper required to build latest lvm from cvs
In-Reply-To: <46A7AB23.7050306@ce.jp.nec.com>
References: <87wswplmgl.fsf@rho.meyering.net> <46A7AB23.7050306@ce.jp.nec.com>
Message-ID: <46A7AC09.2070502@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> lvm_fclose() calls dm_fclose(), which cause the linker to
> bring libdm-file.o in liblvm.a. Then there happens a conflict
> of create_dir().
> 
> Attached is a patch for device-mapper to rename the function
> and export it. It alone fixes the build error.
> 
> A patch for LVM2 to use the exported function will follow.

This is the patch for LVM2.
LVM2's create_dir() is left there for the case LVM2 specific
something could be put in future.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-use-dm_create_dir.patch
Type: text/x-patch
Size: 1275 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070725/7c07d538/attachment.bin>
