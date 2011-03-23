From: Joe Thornber <thornber@redhat.com>
Date: Wed, 23 Mar 2011 08:13:45 -0700
Subject: [PATCH 1/6] Pool locking code
In-Reply-To: <4D8A098C.8060803@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>
	<d2353d5f9081b6eed91ed788af173ddf88dd4bba.1300828168.git.zkabelac@redhat.com>
	<1300888988.14527.28.camel@ubuntu>  <4D8A098C.8060803@redhat.com>
Message-ID: <1300893225.14527.37.camel@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2011-03-23 at 15:54 +0100, Zdenek Kabelac wrote:
> Forget to answer the size question -  >8MB is allocated by the VG
> mempool when
> set of simple linear 7200LVs on 1 PV are in use.

So I think each snapshot/restore of a VG pool of that size is going to
take ~0.1 seconds.  So now my question is how many times are we
expecting to happen during a typical tool invocation?  Your previous
reply suggested it happens just once?

- Joe


