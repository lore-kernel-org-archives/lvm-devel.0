From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 16 Sep 2019 10:21:07 -0400
Subject: dm: introduce DM_GET_TARGET_VERSION
In-Reply-To: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <20190916142106.GA30565@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 16 2019 at  5:55am -0400,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> This patch introduces a new ioctl DM_GET_TARGET_VERSION. It will load a
> target that is specified in the "name" entry in the parameter structure
> and return its version.
> 
> This functionality is intended to be used by cryptsetup, so that it can
> query kernel capabilities before activating the device.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

I've picked this up for 5.4, last change now that merge window is open,
thanks.

Mike


