From: Joe Thornber <thornber@redhat.com>
Date: Thu, 24 Mar 2011 05:21:16 -0700
Subject: [PATCH 1/6] Pool locking code
In-Reply-To: <4D8A437D.9080609@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>
	<d2353d5f9081b6eed91ed788af173ddf88dd4bba.1300828168.git.zkabelac@redhat.com>
	<1300888988.14527.28.camel@ubuntu> <4D8A098C.8060803@redhat.com>
	<1300893225.14527.37.camel@ubuntu> <4D8A1886.1090105@redhat.com>
	<1300905681.25951.3.camel@ubuntu>  <4D8A437D.9080609@redhat.com>
Message-ID: <1300969276.28356.12.camel@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2011-03-23 at 20:01 +0100, Zdenek Kabelac wrote:
> 
> Yes - the locking has rather 'debug' semantic to catch writes to vg
> mempool.
> 
> But I'm not sure what do you mean here by 'set/restore api won't be
> needed' ? 

I had a quick chat about this with Alasdair yesterday.  The plan is to
change the code that updates the VGs so they don't touch the VG data in
the pool, but instead hold those small changes off to one side.

So the steps you seem to be following are:

i) debug lock/unlock api for pool to identify mutating code.  (Useful in
perpetuity for regression tests.)
ii) set/restore api for pool (temporary).
iii) update the mutating code to use set.
iv) gradually get rid of the use of set/restore on a case by case basis.
v) remove the set/restore api

There is an argument that set/restore shouldn't ever go into HEAD, but
is instead something solely useful to you while you do this work.  But
since this work is going to take some time I see no problem with this
going in on the understanding that it comes out again as soon as
possible.

- Joe



