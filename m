From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 25 Jul 2007 16:43:41 -0400
Subject: new device-mapper required to build latest lvm from cvs
In-Reply-To: <20070725201005.GA459@agk.fab.redhat.com>
References: <87wswplmgl.fsf@rho.meyering.net> <46A7AB23.7050306@ce.jp.nec.com>
	<46A7AC09.2070502@ce.jp.nec.com>
	<20070725201005.GA459@agk.fab.redhat.com>
Message-ID: <46A7B5FD.503@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> On Wed, Jul 25, 2007 at 04:01:13PM -0400, Jun'ichi Nomura wrote:
>> This is the patch for LVM2.
>> LVM2's create_dir() is left there for the case LVM2 specific
>> something could be put in future.
> 
> Don't bother: if the functions are identical today, remove the lvm2
> wrapper and have everything call the dm version directly.

OK, then this is a revised version of the patch.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-use-dm_create_dir.patch
Type: text/x-patch
Size: 4183 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070725/3ae5cd4a/attachment.bin>
