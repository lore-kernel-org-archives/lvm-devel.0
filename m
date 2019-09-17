From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 17 Sep 2019 09:39:03 -0400
Subject: dm: introduce DM_GET_TARGET_VERSION
In-Reply-To: <20190917063242.GA10776@infradead.org>
References: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
	<20190916180107.GA725@infradead.org>
	<127b8c4e-a6dc-6d5e-caff-fe1a0ca3a5bb@gmail.com>
	<20190917063242.GA10776@infradead.org>
Message-ID: <20190917133903.GA3612@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 17 2019 at  2:32am -0400,
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Sep 16, 2019 at 08:16:41PM +0200, Milan Broz wrote:
> > 
> > So the main idea behind this was just use already existing functionality
> > in kernel DM, and provide simple user-friendly way to detect some incompatibilites
> > more early. If detection is not there, we just fallback to the old way.
> 
> Well, and the nice way to do that is to actually report the features,
> not some arbitrary version number.  That is have a sysfs file (or
> ioctl for dm if that is the way to go) that reports a list of
> capabilities.  Then userspace checks for that desired capability and
> only tries the feture if it is supported.

A target's version, while opaque and imperfect, has served DM pretty
well for a long time.  Requires discipline when backporting changes but
stable@ version bumps generally don't occur because such a bump triggers
conflicts across the N stable@ kernels.

So I'm not opposed to fined grained reporting of target features.  But
doing so can come later.


