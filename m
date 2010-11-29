From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 23:54:32 +0000
Subject: [PATCH] Scan also special metadata areas (like metadata/dirs) in fmt_from_vgname
In-Reply-To: <4CEFD75D.6060509@redhat.com>
References: <4CEFD75D.6060509@redhat.com>
Message-ID: <20101129235432.GV29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Nov 26, 2010 at 04:50:53PM +0100, Peter Rajnoha wrote:
> We reread labels and metadata from raw devices in fmt_from_vgname function,
> but we forgot to read special metadata areas? (like dirs defined by metadata/dirs
> config setting) Anyway, can someone remind me why we do scanning inside this fn
> at all?
 
We don't.

fmt_from_vgname *just* looks for the VG in the cache.  If it's not there, it
returns nothing.  If it *is* there, it rereads the PV metadata to check it's
still current.  Any scanning is the responsibility of the caller.

> Without this patch, we will fail to find a VG when metadata/dirs is only
> used and there are no other metadata areas (which is itself a strange situation,

Not at all strange.  If that's broken now, I'm afraid the fix lies elsewhere...

Alasdair


