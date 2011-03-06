From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 6 Mar 2011 01:18:08 +0000
Subject: LVM2/libdm/ioctl libdm-iface.c
In-Reply-To: <20110305211719.11626.qmail@sourceware.org>
References: <20110305211719.11626.qmail@sourceware.org>
Message-ID: <20110306011808.GW10767@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Mar 05, 2011 at 09:17:19PM -0000, mbroz at sourceware.org wrote:
> 	This feature is not yet upstream and becuase cryptsetup in next version
> 	uses this flag, it will cause a lot of noise on old kernels.
 
Let's take this as a temporary change then, and once the new code becomes
reasonably widely used, revert this patch, OK?

Alasdair


