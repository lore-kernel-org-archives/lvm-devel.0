From: Petr Rockai <prockai@redhat.com>
Date: Sun, 24 Oct 2010 12:12:06 +0200
Subject: [PATCH 00/05] Add generic property fns for lvm2app, return struct, v2.
In-Reply-To: <1287748270-26875-1-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Fri, 22 Oct 2010 07:51:05 -0400")
References: <1287748270-26875-1-git-send-email-dwysocha@redhat.com>
Message-ID: <87hbgb5289.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Dave Wysochanski <dwysocha@redhat.com> writes:
> This is the modified patchset based on Petr's suggestion of changing
> the return value from 'int' to struct lvm_property_value:
> http://www.redhat.com/archives/lvm-devel/2010-October/msg00068.html

> Returning the struct seems like the approach things are moving, but
> a few details probably still worth considering, especially the exact
> layout of the exported struct lvm_property_value (ABI implications).
> Final submission might be best left to Petr.
I think I almost prefer to have this in tree now and tweak the layouts
etc. afterwards. I think that all that needs to be done is to pad the
bit-field, the union is already 64b wide so we shouldn't need anything
else. I'll have a closer look next week.

> Patchset adds the lvm2app 'get' functions for vg, pv, and lv, and interactive
> tests to exercise the interface.

> The only two lv properties not included now are still the float/percent
> based properties, snap_percent and copy_percent.  These should be
> refactored carefully and I did not want to delay these patches further.
I will sort these out myself as well.

I went through the individual patches and I don't have any specific
comments. So I think all five can go in now, and I'll look at finishing
the two above items and will look into test coverage that we already
have and maybe extend it. Therefore,

Reviewed-by: Petr Rockai <prockai@redhat.com>

Yours,
   Petr.


