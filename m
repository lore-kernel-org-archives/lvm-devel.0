From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 25 Jul 2007 21:32:55 +0100
Subject: new device-mapper required to build latest lvm from cvs
In-Reply-To: <20070725201005.GA459@agk.fab.redhat.com>
References: <87wswplmgl.fsf@rho.meyering.net> <46A7AB23.7050306@ce.jp.nec.com>
	<46A7AC09.2070502@ce.jp.nec.com>
	<20070725201005.GA459@agk.fab.redhat.com>
Message-ID: <20070725203255.GC459@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 25, 2007 at 09:10:05PM +0100, Alasdair G Kergon wrote:
> Don't bother: if the functions are identical today, remove the lvm2
> wrapper and have everything call the dm version directly.

The functions are not quite identical:-)
  1 - a log_sys_error() cleanup missing
  2 - error suppression for read-only filesystems
  
Alasdair
-- 
agk at redhat.com


