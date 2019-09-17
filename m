From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 16 Sep 2019 23:32:42 -0700
Subject: [dm-devel] [PATCH] dm: introduce DM_GET_TARGET_VERSION
In-Reply-To: <127b8c4e-a6dc-6d5e-caff-fe1a0ca3a5bb@gmail.com>
References: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
	<20190916180107.GA725@infradead.org>
	<127b8c4e-a6dc-6d5e-caff-fe1a0ca3a5bb@gmail.com>
Message-ID: <20190917063242.GA10776@infradead.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 16, 2019 at 08:16:41PM +0200, Milan Broz wrote:
> 
> So the main idea behind this was just use already existing functionality
> in kernel DM, and provide simple user-friendly way to detect some incompatibilites
> more early. If detection is not there, we just fallback to the old way.

Well, and the nice way to do that is to actually report the features,
not some arbitrary version number.  That is have a sysfs file (or
ioctl for dm if that is the way to go) that reports a list of
capabilities.  Then userspace checks for that desired capability and
only tries the feture if it is supported.


