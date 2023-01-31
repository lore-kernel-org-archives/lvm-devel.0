From: David Teigland <teigland@redhat.com>
Date: Tue, 31 Jan 2023 09:55:29 -0600
Subject: Need assistance
In-Reply-To: <CAJreVFygf+13+2PM5wYkDQAxyzVDd=nCiP=P4nhi18bUY=W4mQ@mail.gmail.com>
References: <CAJreVFygf+13+2PM5wYkDQAxyzVDd=nCiP=P4nhi18bUY=W4mQ@mail.gmail.com>
Message-ID: <20230131155529.GA16839@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jan 30, 2023 at 06:07:03PM +0530, Gk Gk wrote:
> Hi All,
> 
> 
> I have two nvme disks with different sector sizes of 512 and 4096
> respectively. When I try
> to use them in creating a volume group, it is complaining to set the
> 'allow_mixed_block_sizes' option in lvm.conf file. But I read elsewhere
> that doing this would corrupt data.
> 
> Can anyone explain to me under what specific case/cases  will I loose data
> if I allow mixed blocked sizes ?

If an LV is using one disk, then there is clearly no problem.  If an LV is
using both disks, then we don't know all the issues that might appear --
linear/striped will be fine, but we've seen problems with cache,
writecache, snapshot.  Avoid pvmove or something where the disk under a
logical block might change.

