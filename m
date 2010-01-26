From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 26 Jan 2010 15:57:20 -0500
Subject: [PATCH] Add possibility to exclude internal VG names and uuids in lists returned from liblvm (and lvmcache)
In-Reply-To: <4B5EF8E3.5040401@redhat.com>
References: <4B5EF8E3.5040401@redhat.com>
Message-ID: <1264539440.2459.1.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2010-01-26 at 15:14 +0100, Peter Rajnoha wrote:
> This is related to liblvm and its lvm_list_vg_names() and lvm_list_vg_uuids() functions
> where we should not expose internal VG names/uuids (the ones with "#" prefix )through the
> interface. Otherwise, we could end up with library users opening internal VGs which will
> initiate locking mechanism that won't be cleaned up properly.
> 
> "#orphans_{lvm1, lvm2, pool}" names are treated in a special way, they are truncated first
> to "orphans" and this is used as a part of the lock name then (e.g. while calling lvm_vg_open()).
> When library user calls lvm_vg_close(), the original name "orphans_{lvm1, lvm2, pool}"
> is used directly and therefore no unlock occurs.
> 
> This simple patch adds possibility to exclude those internal VG names and ids in the
> lists provided by lvmcache: lvmcache_get_vgids() and lvmcache_get_vgnames().
> 
> (The actual problem we can observe now occurs while using udisks-lvm-pv-export that is
> called from udisks udev rule. This reserves the lock and prevents, for example, vgcreate
> to succeed...)
> 
> Peter
> 

Looks good Peter.  Reviewed line by line and tested.

Ack.




