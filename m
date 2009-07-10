From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 10 Jul 2009 12:09:23 -0400
Subject: [PATCH] Do not count VG_GLOBAL to lock_count.
In-Reply-To: <4A574BE0.70704@redhat.com>
References: <4A574BE0.70704@redhat.com>
Message-ID: <1247242163.2462.10.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2009-07-10 at 16:10 +0200, Milan Broz wrote:
> Do not count VG_GLOBAL to lock_count.
> 

This description is misleading - it's not the count that matters its the
flag _vg_write_lock_held, and that's set based on the lock type:
	/* We don't bother to reset this until all VG locks are dropped */
	if ((flags & LCK_TYPE_MASK) == LCK_WRITE)
		_vg_write_lock_held = 1;
	else if (!_vg_lock_count)
		_vg_write_lock_held = 0;
}

Wouldn't a better fix just be changing pvscan and vgscan to use
LCK_VG_READ instead of LCK_VG_WRITE since they are not updating
metadata?  Or is there a problem with doing that?

I guess in general I don't like the idea of affecting the count.  Unless
of course we want to call "VG_GLOBAL" not really a vg lock.  But then
the naming seems inconsistent.


