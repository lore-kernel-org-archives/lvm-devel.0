From: Milan Broz <mbroz@redhat.com>
Date: Mon, 13 Jul 2009 17:42:27 +0200
Subject: [PATCH] Do not count VG_GLOBAL to lock_count.
In-Reply-To: <1247242163.2462.10.camel@f10-node1>
References: <4A574BE0.70704@redhat.com> <1247242163.2462.10.camel@f10-node1>
Message-ID: <4A5B55E3.5020606@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski wrote:
> On Fri, 2009-07-10 at 16:10 +0200, Milan Broz wrote:
> Wouldn't a better fix just be changing pvscan and vgscan to use
> LCK_VG_READ instead of LCK_VG_WRITE since they are not updating
> metadata?  Or is there a problem with doing that?

The VG_LOCK thing is one hack, it is a "special" lock...

It was introduced because of cluster, to notify other nodes
about need of metadata cache changes.

Moreover, the real metadata are cached, only if VG_GLOBAL is held.

Anyway, if you want to manipulate with any VG, you have to take
anothe (real) VG locks.

I tried to use the simplest solution - ignore VG_GLOBAL the same way
how lvmcache ingores it

	if (strcmp(vgname, VG_GLOBAL))
		_vgs_locked++;

Your proposal is possible too, but it means than we need to audit all
uses.

I remember that I used some special handling in process_each_pv()
for example if LCK_VG_READ is set...

(It will probably work but I used the simplest solution here.) 
 
> I guess in general I don't like the idea of affecting the count.  Unless
> of course we want to call "VG_GLOBAL" not really a vg lock.  But then
> the naming seems inconsistent.

The whole idea of using special locks for communication between nodes
is misleading but also simple:-)

Milan


