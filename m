From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 26 Jul 2007 14:39:15 -0400
Subject: new device-mapper required to build latest lvm from cvs
In-Reply-To: <46A7BACE.1020100@ce.jp.nec.com>
References: <87wswplmgl.fsf@rho.meyering.net> <46A7AB23.7050306@ce.jp.nec.com>
	<46A7AC09.2070502@ce.jp.nec.com>
	<20070725201005.GA459@agk.fab.redhat.com>
	<20070725203255.GC459@agk.fab.redhat.com>
	<46A7BACE.1020100@ce.jp.nec.com>
Message-ID: <46A8EA53.4080902@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jun'ichi Nomura wrote:
> Alasdair G Kergon wrote:
>> The functions are not quite identical:-)
..
>>   2 - error suppression for read-only filesystems
> 
> It can be brought into dm_create_dir() or we can move logging
> to the outside of dm_create_dir() and let callers do it.
> Which way do you think is better?

And this patch adds EROFS check to libdevmapper version of
_create_dir_recursive() so that they are equivalent.
(The patch is applicable after the log_sys_* macro patch.)

For really making them identical, I think LVM2 should call
dm_init_log() with its own log function.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: dm-dm_create_dir-EROFS-check.patch
Type: text/x-patch
Size: 860 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070726/7a2a4544/attachment.bin>
