From: Joe Thornber <thornber@redhat.com>
Date: Wed, 23 Mar 2011 11:41:21 -0700
Subject: [PATCH 1/6] Pool locking code
In-Reply-To: <4D8A1886.1090105@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>
	<d2353d5f9081b6eed91ed788af173ddf88dd4bba.1300828168.git.zkabelac@redhat.com>
	<1300888988.14527.28.camel@ubuntu> <4D8A098C.8060803@redhat.com>
	<1300893225.14527.37.camel@ubuntu>  <4D8A1886.1090105@redhat.com>
Message-ID: <1300905681.25951.3.camel@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2011-03-23 at 16:57 +0100, Zdenek Kabelac wrote:
> If there would be just 1 vg read for 7200 activate call - obviously
> I'd not
> need to play with this dm_pool locking :)
> 
> So there is 7200 vg reads - which will use this one locked pool with
> my patch set:

ok, so I'm playing catch-up;  This locking functionality is debug only.
In the near term the set/restore api wont be needed at all, at which
point that interface can be removed.  We should leave the locking side
for regression tests.

So I'll ACK the patch.

- Joe


