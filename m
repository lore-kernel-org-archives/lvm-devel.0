From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 14 Sep 2007 19:14:36 -0400
Subject: RFC: testing framework
In-Reply-To: <46EB151D.2080305@ce.jp.nec.com>
References: <87y7f9krex.fsf@rho.meyering.net> <46EB151D.2080305@ce.jp.nec.com>
Message-ID: <46EB15DC.4060901@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jun'ichi Nomura wrote:
> Jim Meyering wrote:
>> There are kludges in t/Makefile.in (symlink creation and LD_LIBRARY_PATH
>> setting), that are required to run the dynamically-linked lvm against the
>> libraries in a just-compiled sibling device-mapper directory.  Thanks to
>> Dave Wysochanski for that tip.  IMHO this is a very strong argument
>> for pulling device-mapper into lvm.  Alasdair, can we do that soon?
>> I'll be happy to submit a patch.
> 
> It didn't work for me because I have device-mapper source directory
> named '../device-mapper.work', instead of '../device-mapper' that
> Makefile assumes.
> There is '--with-dmdir=DIR' option for configure.
> Can the Makefile use it?
> (A patch is attached.)

Also, this patch to allow relative path for '--with-dmdir' might
be helpful.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-configure-allow-relative-path.patch
Type: text/x-patch
Size: 447 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070914/7833087c/attachment.bin>
