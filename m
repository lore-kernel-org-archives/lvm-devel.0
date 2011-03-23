From: Joe Thornber <thornber@redhat.com>
Date: Wed, 23 Mar 2011 07:53:47 -0700
Subject: [PATCH 1/6] Pool locking code
In-Reply-To: <4D8A06F8.3070807@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>
	<d2353d5f9081b6eed91ed788af173ddf88dd4bba.1300828168.git.zkabelac@redhat.com>
	<1300888988.14527.28.camel@ubuntu>  <4D8A06F8.3070807@redhat.com>
Message-ID: <1300892027.14527.29.camel@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2011-03-23 at 15:43 +0100, Zdenek Kabelac wrote:
> It's been my first idea - to copy all chunks to separate buffer - but the VG
> mempool size for large VGs is actually quite big - thus doing always a
> snapshot isn't performance optimal. I'm doing my tests with ~7000LV - and it
> would be quite noticable to copy all the pool chunks with each use of it.

Can you define 'quite big' please?

- Joe



