From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 26 Jul 2007 16:34:20 -0400
Subject: new device-mapper required to build latest lvm from cvs
In-Reply-To: <46A8EA0C.5080403@ce.jp.nec.com>
References: <87wswplmgl.fsf@rho.meyering.net> <46A7AB23.7050306@ce.jp.nec.com>
	<46A7AC09.2070502@ce.jp.nec.com>
	<20070725201005.GA459@agk.fab.redhat.com>
	<20070725203255.GC459@agk.fab.redhat.com>
	<46A7BACE.1020100@ce.jp.nec.com> <46A8EA0C.5080403@ce.jp.nec.com>
Message-ID: <46A9054C.1070907@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jun'ichi Nomura wrote:
> Jun'ichi Nomura wrote:
>> Alasdair G Kergon wrote:
>>> On Wed, Jul 25, 2007 at 09:10:05PM +0100, Alasdair G Kergon wrote:
>>>> Don't bother: if the functions are identical today, remove the lvm2
>>>> wrapper and have everything call the dm version directly.
>>> The functions are not quite identical:-)
>>>   1 - a log_sys_error() cleanup missing
>> I thought they are identical after the macro is expanded.
>> Should I use log_sys_error() in libdevmapper, too?
> 
> OK, this patch copies log_sys_error() macro from LVM2
> and let libdevmapper use it.

Sorry there was a typo in the patch. ("fscanf" -> "scanf")
Attached is a revised patch.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: dm-import-lvm2-log_sys-macros.patch
Type: text/x-patch
Size: 8084 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070726/4f5bfd38/attachment.bin>
