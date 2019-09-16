From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 16 Sep 2019 11:01:07 -0700
Subject: [dm-devel] [PATCH] dm: introduce DM_GET_TARGET_VERSION
In-Reply-To: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <20190916180107.GA725@infradead.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 16, 2019 at 05:55:42AM -0400, Mikulas Patocka wrote:
> This patch introduces a new ioctl DM_GET_TARGET_VERSION. It will load a
> target that is specified in the "name" entry in the parameter structure
> and return its version.
> 
> This functionality is intended to be used by cryptsetup, so that it can
> query kernel capabilities before activating the device.

Well, if you want to query kernel features you better ask for a feature
bitmap than a version number, which can be rather meaningless with
the amount of backporting that is going on.


