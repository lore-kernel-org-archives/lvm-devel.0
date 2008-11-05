From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 05 Nov 2008 10:44:14 -0500
Subject: [PATCH] (1/11) rename vg_read to vg_read_internal
In-Reply-To: <873aie55wj.fsf@eriador.mornfall.net>
References: <873aie55wj.fsf@eriador.mornfall.net>
Message-ID: <1225899854.11788.2.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2008-10-30 at 18:50 +0100, Petr Rockai wrote:
> Hello lvm-devel,
> 
> this is a first patch in my "lvmlib" series. This work is not completely done,
> but it does pass the testsuite. Please note, that the patches are chopped up in
> a somewhat arbitrary manner, as it is fairly hard to come up with a good
> ordering in the pretty long history of the patchset. Also please note that
> parts of these patches, especially early in the series are obsoleted by later
> ones, so it would make sense to at least glance over all of the patches first
> and then go into more detailed review process.
> 
> This first preparatory patch just renames vg_read to vg_read_internal so it's
> easily spotted and the "preferred" vg_read name is freed.
> 
> Yours,
>    Petr.
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel

Looks fine - simple rename, naming choice consistent with the rest of
the code.


