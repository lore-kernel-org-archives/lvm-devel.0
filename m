From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 25 Jul 2007 17:04:14 -0400
Subject: new device-mapper required to build latest lvm from cvs
In-Reply-To: <20070725203255.GC459@agk.fab.redhat.com>
References: <87wswplmgl.fsf@rho.meyering.net> <46A7AB23.7050306@ce.jp.nec.com>
	<46A7AC09.2070502@ce.jp.nec.com>
	<20070725201005.GA459@agk.fab.redhat.com>
	<20070725203255.GC459@agk.fab.redhat.com>
Message-ID: <46A7BACE.1020100@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> On Wed, Jul 25, 2007 at 09:10:05PM +0100, Alasdair G Kergon wrote:
>> Don't bother: if the functions are identical today, remove the lvm2
>> wrapper and have everything call the dm version directly.
> 
> The functions are not quite identical:-)
>   1 - a log_sys_error() cleanup missing

I thought they are identical after the macro is expanded.
Should I use log_sys_error() in libdevmapper, too?

>   2 - error suppression for read-only filesystems

It can be brought into dm_create_dir() or we can move logging
to the outside of dm_create_dir() and let callers do it.
Which way do you think is better?

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


