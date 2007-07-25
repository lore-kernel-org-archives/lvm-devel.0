From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 25 Jul 2007 21:10:05 +0100
Subject: new device-mapper required to build latest lvm from cvs
In-Reply-To: <46A7AC09.2070502@ce.jp.nec.com>
References: <87wswplmgl.fsf@rho.meyering.net> <46A7AB23.7050306@ce.jp.nec.com>
	<46A7AC09.2070502@ce.jp.nec.com>
Message-ID: <20070725201005.GA459@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 25, 2007 at 04:01:13PM -0400, Jun'ichi Nomura wrote:
> This is the patch for LVM2.
> LVM2's create_dir() is left there for the case LVM2 specific
> something could be put in future.

Don't bother: if the functions are identical today, remove the lvm2
wrapper and have everything call the dm version directly.
 
Alasdair
-- 
agk at redhat.com


