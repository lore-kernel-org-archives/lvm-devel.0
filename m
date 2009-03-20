From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 20 Mar 2009 11:00:51 -0400
Subject: liblvm IOCTL/sysfs interface
In-Reply-To: <37d33d830903190434o563ef7a1l7219f87388fbf2da@mail.gmail.com>
References: <37d33d830903190434o563ef7a1l7219f87388fbf2da@mail.gmail.com>
Message-ID: <1237561251.2493.11.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2009-03-19 at 17:04 +0530, Sandeep K Sinha wrote:
> Hi all,
> 
> I  would like to know if there is any means currently to know the complete
> geometry of a LVM volume.
> e.g, If a volume has 3 PV(targets).
> 
> So, we should be able to extract some information like.
> 
> Name of Volume.
> Name of Volume Group.
> Name, Range and size for each of the Physical devices involved.
> 
> I execute the following steps.
> 
> 1. pvcreate /dev/sda5 /dev/sda6
> 2. vgcreate vg /dev/sda5 /dev/sda6
> 3. lvcreate vg -L 5G
> 
> So, I should see the information like.
> 
> lvol0
> vg
> target1 - /dev/sda5 ----  0 -- 10000 ( BEGIN  -- Length )
> target2 - /dev/sda6 ----  10001 -- 4000
> 
> 
> We do maintain these informations inside the kernel, We should atleast
> have an ioctl or sysfs based interface to extract
> these information.
> 

Did you try "dmsetup table"?  You can strace this and/or examine the
source code - upstream git repo (see tools/dmsetup.c and
liblvm/libdevmapper.h):
git://sources.redhat.com/git/lvm2

There is also the "lvdisplay --maps" and "pvdisplay --maps" but it
sounds like you're wanting more of what dmsetup provides.

> Liblvm is under development, won't it be of a good use to provide such
> a functionality.
> 

Thank you for the suggestion and I will think about this some more.
Even though we have the ability to provide this information today as
shown by the above commands, it may be useful to also provide this in
liblvm in a more convenient API, such as lvm_lv_get_pe_layout((), which
would return a list of information as provided above.  With simple
linear LVs this is straightforward but a bit more complex with snaps and
mirrors, and stacked LVs.


